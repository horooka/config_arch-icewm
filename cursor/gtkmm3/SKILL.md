name: gtkmm3
description: C++17 gtkmm3 development with strict style rules
steps: [Scaffold UI, wire signals, build test]
---
# Gtkmm3.0 on C++17

- Avoid extra spacing
- Use auto keyword only for lambdas
- Implement recursive lambdas via self-reference
- Check build with build part of ./buildrun.sh script for errors and warnings
- Warn about intent to multifile changes in existing code
