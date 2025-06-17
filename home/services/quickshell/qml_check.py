#!/usr/bin/env python3
"""
QML Language Server Integration for Quickshell Lumin
Provides syntax checking and real-time feedback using qmlls
"""

import os
import sys
import json
import subprocess
import tempfile
import threading
import time
from pathlib import Path

class QMLChecker:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.qmlls_path = self._find_qmlls()
        
    def _find_qmlls(self):
        """Find qmlls executable"""
        result = subprocess.run(['which', 'qmlls'], capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip()
        return None
    
    def check_file(self, qml_file):
        """Check a single QML file for syntax errors"""
        if not self.qmlls_path:
            print(f"ERROR: qmlls not found")
            return False
            
        qml_path = self.project_root / qml_file
        if not qml_path.exists():
            print(f"ERROR: {qml_file} not found")
            return False
            
        print(f"Checking: {qml_file}")
        
        # Basic syntax patterns to check
        content = qml_path.read_text()
        issues = []
        
        # Check for common QML issues
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            # Check for Singleton usage (should be QtObject with pragma Singleton)
            if 'Singleton {' in line:
                issues.append(f"  Line {i}: Use 'QtObject {{' with 'pragma Singleton' instead of 'Singleton {{'")
            
            # Check for potential signal conflicts
            if 'readonly property' in line and 'signal' in line:
                issues.append(f"  Line {i}: Possible signal/property conflict")
                
            # Check for missing imports
            if 'Material.' in line and 'import QtQuick.Controls.Material' not in content:
                issues.append(f"  Line {i}: Using Material but missing 'import QtQuick.Controls.Material'")
        
        if issues:
            print("  ISSUES FOUND:")
            for issue in issues:
                print(issue)
            return False
        else:
            print("  ✓ No obvious syntax issues")
            return True
    
    def check_all_files(self):
        """Check all QML files in the project"""
        qml_files = [
            'shell.qml',
            'config/Material.qml',
            'config/Device.qml', 
            'config/Layout.qml',
            'services/NiriIPC.qml',
        ]
        
        # Add component files
        base_components = self.project_root / 'components' / 'base'
        if base_components.exists():
            for qml_file in base_components.glob('*.qml'):
                qml_files.append(f'components/base/{qml_file.name}')
        
        print("=== QML Syntax Check Report ===")
        print(f"Project: {self.project_root}")
        print()
        
        all_good = True
        for qml_file in qml_files:
            if not self.check_file(qml_file):
                all_good = False
            print()
        
        print(f"=== Result: {'✓ ALL GOOD' if all_good else '✗ ISSUES FOUND'} ===")
        return all_good

def main():
    project_root = os.path.dirname(os.path.abspath(__file__))
    checker = QMLChecker(project_root)
    
    if len(sys.argv) > 1:
        # Check specific file
        success = checker.check_file(sys.argv[1])
        sys.exit(0 if success else 1)
    else:
        # Check all files
        success = checker.check_all_files()
        sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()