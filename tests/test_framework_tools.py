"""Local contract checks; no installers, authentication, or cloud writes are run."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('validator', ROOT / 'scripts/validate-fabric-notebook.py')
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)
TENANT = '11111111-1111-1111-1111-111111111111'
WORKSPACE = '22222222-2222-2222-2222-222222222222'
MCP = ROOT / 'AI Framework/skills/install-claude-code/scripts/configure-fabric-mcp.sh'


def notebook():
    return {'nbformat': 4, 'metadata': {}, 'cells': [
        {'cell_type': 'markdown', 'source': '# Inventory\nValidate an inventory snapshot.'},
        {'cell_type': 'code', 'metadata': {'tags': ['parameters']}, 'source': ['LIMIT = 10'], 'outputs': []},
        {'cell_type': 'code', 'source': 'print("Validation complete")', 'outputs': []},
    ]}


class NotebookTests(unittest.TestCase):
    def test_generic_workload_passes_without_specific_api_or_merge(self):
        self.assertTrue(all(validator.validate(notebook()).values()))

    def test_lakehouse_requirement_is_explicit(self):
        n = notebook()
        self.assertFalse(all(validator.validate(n, True).values()))
        n['metadata'] = {'dependencies': {'lakehouse': {'default_lakehouse': WORKSPACE}}}
        self.assertTrue(all(validator.validate(n, True).values()))

    def test_retained_outputs_fail(self):
        n = notebook()
        n['cells'][-1]['outputs'] = [{'output_type': 'stream', 'text': 'data'}]
        self.assertFalse(all(validator.validate(n).values()))

    def test_literal_credential_fails(self):
        n = notebook()
        n['cells'][1]['source'] = 'CLIENT_SECRET = "synthetic-test-value"'
        self.assertFalse(all(validator.validate(n).values()))

    def test_missing_parameters_fail(self):
        n = notebook()
        n['cells'][1]['metadata'] = {}
        self.assertFalse(all(validator.validate(n).values()))

    def test_malformed_input_does_not_echo_content(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'invalid.ipynb'
            path.write_text('synthetic-private-value')
            run = subprocess.run(['python3', str(ROOT / 'scripts/validate-fabric-notebook.py'), str(path)], capture_output=True, text=True)
            self.assertEqual(run.returncode, 2)
            self.assertNotIn('synthetic-private-value', run.stdout + run.stderr)


class HelperTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.log = self.directory / 'calls'
        self.env = dict(os.environ, PATH=str(self.directory) + ':' + os.environ['PATH'], TEST_CALLS=str(self.log), TEST_TENANT=TENANT)
        self.stub('node', 'echo v22.0.0')
        self.stub('npm', 'exit 0')
        self.stub('npx', 'exit 0')
        self.stub('az', 'printf "%s\\n" "$TEST_TENANT"')
        self.stub('claude', '''if [ "$1" = --version ]; then echo 'Claude test'; exit 0; fi
if [ "$2" = get ]; then printf '%s\\n' "$TEST_MCP_OUTPUT"; exit "${TEST_MCP_STATUS:-0}"; fi
printf '%s\\n' "$*" >> "$TEST_CALLS"
''')
        self.env['TEST_MCP_OUTPUT'] = 'Type: stdio\nCommand: npx\nArgs: -y @microsoft/fabric-mcp@latest server start --mode all\nEnvironment:\n  AZURE_TOKEN_CREDENTIALS=AzureCliCredential\nStatus: ✓ Connected'

    def stub(self, name, body):
        path = self.directory / name
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def run_mcp(self, mode):
        return subprocess.run(['bash', str(MCP), mode, '--tenant-id', TENANT, '--workspace-id', WORKSPACE], env=self.env, text=True, capture_output=True)

    def test_expected_connected_configuration_passes(self):
        self.assertEqual(self.run_mcp('--verify').returncode, 0)
        self.assertFalse(self.log.exists())

    def test_unknown_connection_status_fails(self):
        self.env['TEST_MCP_OUTPUT'] = self.env['TEST_MCP_OUTPUT'].replace('✓ Connected', 'Unknown')
        self.assertEqual(self.run_mcp('--verify').returncode, 5)

    def test_wrong_tenant_blocks_configuration(self):
        self.env['TEST_TENANT'] = WORKSPACE
        self.assertEqual(self.run_mcp('--configure').returncode, 3)
        self.assertFalse(self.log.exists())

    def test_existing_different_entry_is_not_overwritten_or_printed(self):
        self.env['TEST_MCP_OUTPUT'] = 'Type: http\nAuthorization: synthetic-private-value'
        result = self.run_mcp('--configure')
        self.assertEqual(result.returncode, 4)
        self.assertNotIn('synthetic-private-value', result.stdout + result.stderr)
        self.assertFalse(self.log.exists())

    def test_missing_entry_added_in_local_scope(self):
        self.env.update(TEST_MCP_STATUS='1', TEST_MCP_OUTPUT='No MCP server found with name: fabric')
        self.assertEqual(self.run_mcp('--configure').returncode, 0)
        args = self.log.read_text()
        self.assertIn('--scope local', args)
        self.assertIn('AzureCliCredential', args)
        self.assertNotIn('remove', args)

    def test_inspection_error_does_not_add_server(self):
        self.env.update(TEST_MCP_STATUS='1', TEST_MCP_OUTPUT='Unexpected CLI failure')
        self.assertEqual(self.run_mcp('--configure').returncode, 4)
        self.assertFalse(self.log.exists())

    def test_master_installer_routes_to_official_skills_only(self):
        self.stub('apm', 'printf "%s\\n" "$*" >> "$TEST_CALLS"')
        result = subprocess.run(['bash', str(ROOT / 'scripts/install-framework.sh'), '--fabric'], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().strip(), 'install microsoft/skills-for-fabric --global --target codex --only apm --update')

    def test_existing_claude_check_does_not_install(self):
        script = MCP.with_name('install-claude-code.sh')
        result = subprocess.run(['bash', str(script), '--check'], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())


if __name__ == '__main__':
    unittest.main()
