# trews.sh - Usage Examples

This document demonstrates various ways to use the `trews.sh` script with real examples and expected output.

## Setup for Examples

Let's assume we have the following directory structure for our examples:

```bash
/project-demo/
├── node_modules/
│   └── (many files)
├── src/
│   ├── main.js
│   ├── utils/
│   │   ├── helper.js
│   │   └── formatter.js
│   └── components/
│       ├── Button.js
│       └── Form.js
├── tests/
│   ├── unit/
│   │   └── test-main.js
│   └── integration/
│       └── test-app.js
├── .git/
│   └── (many files)
├── .vscode/
│   └── settings.json
├── build/
│   └── app.min.js
├── Code?DELETE/
│   └── old-version.js
└── README.md
```

## Example 1: Basic Usage

```bash
./trews.sh
```

**Expected Output:**

```bash
/project-demo
├── README.md
└── src
    ├── components
    │   ├── Button.js
    │   └── Form.js
    ├── main.js
    └── utils
        ├── formatter.js
        └── helper.js
└── tests
    ├── integration
    │   └── test-app.js
    └── unit
        └── test-main.js

7 directories, 7 files
```

*Note: By default, the script ignores node_modules, .git, .vscode, Code?DELETE, and build directories based on the default ignores in the script.*

## Example 2: Using the Clipboard Option

```bash
./trews.sh -c
```

**Expected Output:**
Same as Example 1, but with an additional message:

```bash
Output copied to clipboard!
```

## Example 3: Specifying a Directory

```bash
./trews.sh src
```

**Expected Output:**

```bash
/project-demo/src
├── components
│   ├── Button.js
│   └── Form.js
├── main.js
└── utils
    ├── formatter.js
    └── helper.js

2 directories, 5 files
```

## Example 4: Adding Additional Ignore Patterns

```bash
./trews.sh -i "*.js"
```

**Expected Output:**

```bash
/project-demo
├── README.md
└── src
    ├── components
    │   
    └── utils
        
└── tests
    ├── integration
    │   
    └── unit
        

7 directories, 1 file
```

*Note: This adds "*.js" to the ignore list along with the default ignores.*

## Example 5: Disabling Default Ignore Patterns

```bash
./trews.sh -n
```

**Expected Output:**

```bash
/project-demo
├── .git
│   └── (many files shown)
├── .vscode
│   └── settings.json
├── Code?DELETE
│   └── old-version.js
├── README.md
├── build
│   └── app.min.js
├── node_modules
│   └── (many files shown)
└── src
    ├── components
    │   ├── Button.js
    │   └── Form.js
    ├── main.js
    └── utils
        ├── formatter.js
        └── helper.js
└── tests
    ├── integration
    │   └── test-app.js
    └── unit
        └── test-main.js

Many directories, many files
```

*Note: Without default ignores, everything is shown, including normally hidden directories.*

## Example 6: Using a Custom Config File

```bash
./trews.sh -f /path/to/custom-ignore.json
```

**Expected Output:**
Depends on the content of the custom config file, but similar to other examples with different ignore patterns applied.

## Example 7: Limiting Directory Depth

```bash
./trews.sh -- -L 2
```

**Expected Output:**

```bash
/project-demo
├── README.md
└── src
    ├── components
    ├── main.js
    └── utils
└── tests
    ├── integration
    └── unit

5 directories, 2 files
```

*Note: The -L 2 option is passed to the tree command to limit directory depth.*

## Example 8: Showing File Sizes

```bash
./trews.sh -- -h
```

**Expected Output:**

```bash
/project-demo
├── [ 2.3K]  README.md
└── [   96]  src
    ├── [   96]  components
    │   ├── [ 1.2K]  Button.js
    │   └── [ 3.5K]  Form.js
    ├── [ 845]  main.js
    └── [   96]  utils
        ├── [ 1.1K]  formatter.js
        └── [ 520]  helper.js
└── [   96]  tests
    ├── [   96]  integration
    │   └── [ 1.5K]  test-app.js
    └── [   96]  unit
        └── [ 1.2K]  test-main.js

7 directories, 7 files
```

*Note: The -h option is passed to tree to show file sizes.*

## Example 9: Combining Multiple Options

```bash
./trews.sh -c -i "test*" -- -L 2 -h
```

**Expected Output:**

```bash
/project-demo
├── [ 2.3K]  README.md
└── [   96]  src
    ├── [   96]  components
    ├── [ 845]  main.js
    └── [   96]  utils
└── [   96]  tests
    ├── [   96]  integration
    └── [   96]  unit

5 directories, 2 files
Output copied to clipboard!
```

*Note: This combines multiple features: clipboard, additional ignore patterns, and passing options to tree.*

## Example 10: Using Directory-Specific Ignores

Assuming we have the following trew-ignore.json in the script directory:

```json
{
  "general_ignores": [
    "build",
    "dist"
  ],
  "directory_ignores": {
    "/project-demo": [
      "tests"
    ]
  }
}
```

```bash
./trews.sh
```

**Expected Output:**

```bash
/project-demo
Applied directory-specific ignores for: /project-demo
├── README.md
└── src
    ├── components
    │   ├── Button.js
    │   └── Form.js
    ├── main.js
    └── utils
        ├── formatter.js
        └── helper.js

3 directories, 6 files
```

*Note: The script applies both general ignores (build, dist) and directory-specific ignores (tests) when in the /project-demo directory.*

## Example 11: Getting Tree Help

```bash
./trews.sh -t
```

**Expected Output:**
Displays the tree command's help page using less, allowing you to navigate through the options with keyboard controls.

## Additional Notes

1. **Clipboard Support**:
   - The `-c` option requires the universal-copy.sh script to be properly installed in the same directory as trews.sh
   - If universal-copy.sh isn't available, you'll see a warning message
   - For SSH sessions, universal-copy.sh attempts to use OSC 52 escape sequences to copy to the local clipboard

2. **Configuration File Format**:
   Make sure your trew-ignore.json follows the correct format with general_ignores and directory_ignores sections.

3. **Passing Custom Options to Tree**:
   Any unrecognized option or options after -- are passed directly to the tree command.
