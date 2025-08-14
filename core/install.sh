#!/bin/bash

# اسکریپت نصب پروژه تبدیل Word به Markdown
# این اسکریپت پروژه را در هر فولدری قابل استفاده می‌کند

# تنظیم رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# نمایش عنوان
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  نصب پروژه تبدیل Word به MD   ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# پیدا کردن مسیر اسکریپت
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${GREEN}📁 مسیر پروژه: $SCRIPT_DIR${NC}"
echo ""

# بررسی وجود فایل‌های مورد نیاز
REQUIRED_FILES=(
    "cleaner.lua"
    "clean_markdown.py"
    "convert_docx_to_clean_md.sh"
)

# بررسی وجود Makefile در فولدر اصلی
if [ ! -f "$SCRIPT_DIR/../Makefile" ]; then
    echo -e "  ❌ Makefile در فولدر اصلی یافت نشد!"
    exit 1
fi

echo -e "${YELLOW}🔍 بررسی فایل‌های مورد نیاز...${NC}"
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ✅ $file"
    else
        echo -e "  ❌ $file - یافت نشد!"
        exit 1
    fi
done

echo ""

# تنظیم مجوزهای اجرا
echo -e "${YELLOW}🔧 تنظیم مجوزهای اجرا...${NC}"
chmod +x "$SCRIPT_DIR/convert_docx_to_clean_md.sh"
chmod +x "$SCRIPT_DIR/clean_markdown.py"
echo -e "  ✅ مجوزهای اجرا تنظیم شدند"

# ایجاد لینک نمادین در /usr/local/bin (اختیاری)
echo ""
echo -e "${YELLOW}🔗 ایجاد لینک نمادین (اختیاری)...${NC}"
read -p "آیا می‌خواهید اسکریپت‌ها در PATH قرار بگیرند؟ (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -w "/usr/local/bin" ]; then
        sudo ln -sf "$SCRIPT_DIR/convert_docx_to_clean_md.sh" "/usr/local/bin/docx2md"
        sudo ln -sf "$SCRIPT_DIR/clean_markdown.py" "/usr/local/bin/clean-md"
        echo -e "  ✅ لینک‌های نمادین ایجاد شدند:"
        echo -e "     docx2md -> تبدیل Word به Markdown"
        echo -e "     clean-md -> تمیز کردن Markdown"
    else
        echo -e "  ⚠️  نیاز به دسترسی sudo برای ایجاد لینک نمادین"
        echo -e "     می‌توانید دستی ایجاد کنید:"
        echo -e "     sudo ln -sf $SCRIPT_DIR/convert_docx_to_clean_md.sh /usr/local/bin/docx2md"
    fi
else
    echo -e "  ℹ️  لینک نمادین ایجاد نشد"
fi

# ایجاد فایل پیکربندی
echo ""
echo -e "${YELLOW}⚙️  ایجاد فایل پیکربندی...${NC}"
CONFIG_FILE="$SCRIPT_DIR/../config.env"
cat > "$CONFIG_FILE" << EOF
# پیکربندی پروژه تبدیل Word به Markdown
PROJECT_DIR="$SCRIPT_DIR/.."
CORE_DIR="$SCRIPT_DIR"
LUA_FILTER="$SCRIPT_DIR/cleaner.lua"
PYTHON_SCRIPT="$SCRIPT_DIR/clean_markdown.py"

# تنظیمات پیش‌فرض
DEFAULT_OUTPUT_SUFFIX="_clean.md"
MEDIA_FOLDER="media"
EOF

echo -e "  ✅ فایل پیکربندی ایجاد شد: $CONFIG_FILE"

# ایجاد اسکریپت wrapper
echo ""
echo -e "${YELLOW}📝 ایجاد اسکریپت wrapper...${NC}"
WRAPPER_FILE="$SCRIPT_DIR/../run.sh"
cat > "$WRAPPER_FILE" << 'EOF'
#!/bin/bash
# اسکریپت wrapper برای اجرا از هر فولدری

# پیدا کردن مسیر پروژه
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$PROJECT_DIR/core"

# اجرای اسکریپت اصلی
"$CORE_DIR/convert_docx_to_clean_md.sh" "$@"
EOF

chmod +x "$WRAPPER_FILE"
echo -e "  ✅ اسکریپت wrapper ایجاد شد: $WRAPPER_FILE"

# نمایش راهنمای استفاده
echo ""
echo -e "${GREEN}🎉 نصب با موفقیت انجام شد!${NC}"
echo ""
echo -e "${YELLOW}📖 نحوه استفاده:${NC}"
echo ""
echo -e "1️⃣  از فولدر پروژه:"
echo -e "   ./core/convert_docx_to_clean_md.sh input.docx output.md"
echo -e "   make convert INPUT=input.docx OUTPUT=output.md"
echo ""
echo -e "2️⃣  از هر فولدری:"
echo -e "   $SCRIPT_DIR/convert_docx_to_clean_md.sh input.docx output.md"
echo -e "   $SCRIPT_DIR/../run.sh input.docx output.md"
echo ""

if command -v docx2md &> /dev/null; then
    echo -e "3️⃣  از هر جای سیستم (اگر لینک نمادین ایجاد شده):"
    echo -e "   docx2md input.docx output.md"
    echo ""
fi

echo -e "${BLUE}💡 نکته: برای استفاده از Makefile، از فولدر پروژه استفاده کنید${NC}"
echo -e "${BLUE}   یا مسیر کامل را مشخص کنید: make -f $SCRIPT_DIR/Makefile convert${NC}"
echo ""

# تست اسکریپت
echo -e "${YELLOW}🧪 تست اسکریپت...${NC}"
if [ -f "$SCRIPT_DIR/../book.docx" ]; then
    echo -e "  📄 فایل نمونه book.docx یافت شد"
    echo -e "  🧪 می‌توانید تست کنید:"
    echo -e "     $SCRIPT_DIR/../run.sh book.docx test.md"
else
    echo -e "  ℹ️  فایل نمونه یافت نشد"
fi

echo ""
echo -e "${GREEN}✅ پروژه آماده استفاده است!${NC}"