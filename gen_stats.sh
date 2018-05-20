#!/bin/bash
LINES=`find modules -type f -name '*.rb' -exec cat {} \; | wc -l`
echo "Lines of code: $LINES"
