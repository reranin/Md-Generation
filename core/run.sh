#!/bin/bash
# اسکریپت wrapper برای اجرا از هر فولدری

# پیدا کردن مسیر پروژه
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# اجرای اسکریپت اصلی
"$SCRIPT_DIR/convert_docx_to_clean_md.sh" "$@"
