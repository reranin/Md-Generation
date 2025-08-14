# تبدیل‌کننده Word به Markdown تمیز 📝

این پروژه ابزاری کامل برای تبدیل فایل‌های Word (.docx) به Markdown تمیز است که تمام عناصر ناخواسته مانند TOC، span HTML و شناسه‌های {#...} را حذف می‌کند.

## فایل‌های موجود

- **`cleaner.lua`**: فیلتر Pandoc پیشرفته برای حذف عناصر ناخواسته
- **`clean_markdown.py`**: اسکریپت Python برای تمیز کردن نهایی
- **`convert_docx_to_clean_md.sh`**: اسکریپت کامل و خودکار برای تبدیل
- **`book.docx`**: فایل Word نمونه (ورودی)
- **`book_clean.md`**: فایل Markdown تمیز شده (خروجی)
- **`media/`**: پوشه فایل‌های media استخراج شده

## ویژگی‌ها

✅ حذف کامل TOC های Word  
✅ حذف تمام تگ‌های span HTML  
✅ حذف شناسه‌های {#...}  
✅ حذف لینک‌های TOC مثل [15](#_Toc…)  
✅ حذف لینک‌های تودرتو  
✅ پشتیبانی از فایل‌های .docx  
✅ استخراج خودکار فایل‌های media  
✅ تبدیل به فرمت GitHub Flavored Markdown (GFM)  

## پیش‌نیازها

- **Pandoc**: برای تبدیل فایل‌ها
- **Python 3.6+**: برای تمیز کردن نهایی
- **Bash**: برای اجرای اسکریپت‌ها

### نصب Pandoc

```bash
# macOS
brew install pandoc

# Ubuntu/Debian
sudo apt update
sudo apt install pandoc

# CentOS/RHEL
sudo yum install pandoc
```

## نصب و راه‌اندازی

### نصب خودکار
```bash
# اجرای اسکریپت نصب
./install.sh

# این اسکریپت:
# - مجوزهای اجرا را تنظیم می‌کند
# - فایل پیکربندی ایجاد می‌کند
# - اسکریپت wrapper ایجاد می‌کند
# - لینک نمادین در PATH ایجاد می‌کند (اختیاری)
```

## نحوه استفاده

### روش 1: استفاده از فولدر پروژه (توصیه شده)

```bash
# تبدیل فایل با نام خودکار
./core/convert_docx_to_clean_md.sh input/book.docx

# تبدیل فایل با نام خروجی مشخص
./core/convert_docx_to_clean_md.sh input/book.docx output/book_clean.md

# استفاده از Makefile
make convert INPUT=input/book.docx OUTPUT=output/book_clean.md
make convert-auto INPUT=input/book.docx

# تبدیل تمام فایل‌های Word در فولدر input
make convert-input
```

### روش 2: استفاده از هر فولدری

```bash
# استفاده از اسکریپت wrapper
/Users/mazidi/Desktop/pandoc/run.sh input.docx output.md

# استفاده مستقیم از اسکریپت اصلی
/Users/mazidi/Desktop/pandoc/convert_docx_to_clean_md.sh input.docx output.md

# استفاده از Makefile از فولدر دیگر
make -f /Users/mazidi/Desktop/pandoc/Makefile convert INPUT=input.docx OUTPUT=output.md
```

### روش 3: استفاده دستی از Pandoc

```bash
# مرحله 1: تبدیل با pandoc و فیلتر Lua
pandoc "book.docx" \
  -t gfm \
  -o "temp.md" \
  --lua-filter="/Users/mazidi/Desktop/pandoc/cleaner.lua" \
  --extract-media="media" \
  --wrap=none

# مرحله 2: تمیز کردن نهایی
python3 /Users/mazidi/Desktop/pandoc/clean_markdown.py temp.md book_clean.md

# حذف فایل موقت
rm temp.md
```

### روش 3: استفاده مستقیم از فیلتر Lua

```bash
pandoc input.docx --lua-filter=cleaner.lua -o output.md
```

## پارامترهای اسکریپت

| پارامتر | توضیح |
|---------|-------|
| `فایل_ورودی.docx` | فایل Word ورودی (اجباری) |
| `فایل_خروجی.md` | فایل Markdown خروجی (اختیاری) |

## نمونه خروجی

```
================================
  تبدیل Word به Markdown تمیز   
================================

🚀 شروع فرآیند تبدیل...
📁 فایل ورودی: book.docx
📁 فایل خروجی: book_clean.md

📝 مرحله 1: تبدیل با pandoc و فیلتر Lua...
✅ تبدیل pandoc با موفقیت انجام شد
🧹 مرحله 2: تمیز کردن نهایی با Python...
✅ تمیز کردن نهایی با موفقیت انجام شد

🎉 عملیات با موفقیت انجام شد!
📁 فایل نهایی: book_clean.md
📁 پوشه media: media/

📊 آمار فایل:
  تعداد خطوط: 6962
  حجم فایل: 436K
```

## ساختار پروژه

```
pandoc/
├── 📄 README.md                    # راهنمای کامل پروژه
├── 📋 Makefile                     # ابزار مدیریت پروژه
├── ⚙️  config.env                   # فایل پیکربندی
├── 📄 run.sh                       # اسکریپت wrapper
├── 📁 core/                        # فایل‌های اصلی
│   ├── 🔧 cleaner.lua              # فیلتر Lua پیشرفته
│   ├── 🐍 clean_markdown.py        # اسکریپت Python
│   ├── 🚀 convert_docx_to_clean_md.sh # اسکریپت اصلی
│   └── 📄 install.sh               # اسکریپت نصب خودکار
├── 📁 input/                       # فایل‌های Word ورودی
│   └── 📄 book.docx                # فایل Word نمونه
├── 📁 output/                      # فایل‌های Markdown خروجی
│   └── 📄 book_clean.md            # فایل Markdown تمیز شده
└── 📁 media/                       # فایل‌های media
    └── 🖼️ image1.png
```

## تنظیمات فیلتر Lua

فیلتر `cleaner.lua` دارای تنظیمات قابل تغییر است:

```lua
local config = {
  remove_toc_links = true,      # حذف لینک‌های TOC
  remove_span_tags = true,      # حذف تگ‌های span
  remove_identifiers = true,    # حذف شناسه‌ها
  remove_classes = true,        # حذف کلاس‌ها
  remove_attributes = true,     # حذف ویژگی‌ها
  clean_headers = true,         # تمیز کردن Headerها
  clean_paragraphs = true,      # تمیز کردن پاراگراف‌ها
  clean_links = true,           # تمیز کردن لینک‌ها
  verbose = false               # نمایش لاگ
}
```

## عیب‌یابی

### خطای "pandoc نصب نشده است"
```bash
# macOS
brew install pandoc

# Ubuntu/Debian
sudo apt install pandoc
```

### خطای "Python3 نصب نشده است"
```bash
# macOS
brew install python3

# Ubuntu/Debian
sudo apt install python3
```

### خطای مجوز اجرا
```bash
chmod +x core/convert_docx_to_clean_md.sh
chmod +x core/clean_markdown.py
```

### خطای encoding
اطمینان حاصل کنید که فایل‌های ورودی با encoding UTF-8 ذخیره شده‌اند.

## مشارکت

برای مشارکت در پروژه:
1. Fork کنید
2. Branch جدید ایجاد کنید
3. تغییرات خود را commit کنید
4. Pull Request ارسال کنید

## مجوز

این پروژه تحت مجوز MIT منتشر شده است.

## پشتیبانی

در صورت بروز مشکل یا سوال، لطفاً issue جدید ایجاد کنید. 


# تبدیل‌کننده Markdown به فرمت‌های مختلف 📝

این اسکریپت Python فایل‌های Markdown را به فرمت‌های مختلف تبدیل می‌کند.

## ویژگی‌ها

✅ **تبدیل به DOCX** - با قابلیت استفاده از template  
✅ **تبدیل به HTML** - با استایل‌های زیبا و TOC  
✅ **تبدیل به PDF** - نیاز به wkhtmltopdf دارد  
✅ **Template های پیش‌فرض** - CSS و DOCX  
✅ **پشتیبانی از فونت‌های فارسی/عربی**  
✅ **رابط خط فرمان ساده**  

## پیش‌نیازها

- **Python 3.6+**
- **Pandoc** - برای تبدیل فایل‌ها
- **wkhtmltopdf** - برای تبدیل به PDF (اختیاری)

### نصب پیش‌نیازها

```bash
# macOS
brew install pandoc
brew install wkhtmltopdf  # اختیاری برای PDF

# Ubuntu/Debian
sudo apt install pandoc
sudo apt install wkhtmltopdf  # اختیاری برای PDF
```

## نحوه استفاده

### تبدیل ساده

```bash
# تبدیل به تمام فرمت‌ها
python3 core/convert_md_to_formats.py input.md

# تبدیل به فرمت خاص
python3 core/convert_md_to_formats.py input.md --formats docx,html

# تعیین پوشه خروجی
python3 core/convert_md_to_formats.py input.md --output-dir my_output
```

### ایجاد Template ها

```bash
# ایجاد فایل‌های template پیش‌فرض
python3 core/convert_md_to_formats.py input.md --create-templates
```

### استفاده از Template های سفارشی

```bash
# استفاده از CSS سفارشی
python3 core/convert_md_to_formats.py input.md --css-template my_style.css

# استفاده از DOCX template
python3 core/convert_md_to_formats.py input.md --docx-template my_template.docx
```

## پارامترها

| پارامتر | توضیح | پیش‌فرض |
|---------|-------|----------|
| `input_file` | فایل Markdown ورودی | - |
| `-o, --output-dir` | پوشه خروجی | `output` |
| `-f, --formats` | فرمت‌های خروجی | `docx,html,pdf` |
| `--create-templates` | ایجاد template های پیش‌فرض | `False` |
| `--css-template` | فایل CSS برای HTML | - |
| `--docx-template` | فایل DOCX template | - |

## نمونه‌های استفاده

### مثال 1: تبدیل ساده
```bash
python3 core/convert_md_to_formats.py output/book_clean.md
```

### مثال 2: تبدیل به DOCX و HTML
```bash
python3 core/convert_md_to_formats.py output/book_clean.md --formats docx,html
```

### مثال 3: ایجاد template ها
```bash
python3 core/convert_md_to_formats.py output/book_clean.md --create-templates
```

### مثال 4: استفاده از template سفارشی
```bash
python3 core/convert_md_to_formats.py output/book_clean.md \
  --css-template template.css \
  --docx-template template.docx
```

## فایل‌های تولید شده

### Template ها
- **`template.css`** - استایل پیش‌فرض برای HTML
- **`template.docx`** - template پیش‌فرض برای DOCX

### فایل‌های خروجی
- **`.docx`** - فایل Word با قابلیت ویرایش
- **`.html`** - فایل HTML با استایل‌های زیبا
- **`.pdf`** - فایل PDF (نیاز به wkhtmltopdf)

## ویژگی‌های HTML

✅ **طراحی ریسپانسیو** - سازگار با موبایل و دسکتاپ  
✅ **فونت‌های زیبا** - Segoe UI و Tahoma  
✅ **رنگ‌بندی حرفه‌ای** - آبی، قرمز و بنفش  
✅ **جدول‌های زیبا** - با استایل‌های مدرن  
✅ **تصاویر بهینه** - با سایه و گردی گوشه  
✅ **فهرست مطالب** - TOC خودکار  
✅ **پشتیبانی از RTL** - برای زبان‌های فارسی/عربی  

## ویژگی‌های DOCX

✅ **فونت‌های استاندارد** - سازگار با Word  
✅ **استایل‌های پیش‌فرض** - Heading، Paragraph  
✅ **قابلیت ویرایش** - در Microsoft Word  
✅ **حفظ ساختار** - Headers، Lists، Tables  

## عیب‌یابی

### خطای "pandoc نصب نشده است"
```bash
brew install pandoc
```

### خطای "wkhtmltopdf نصب نشده است"
```bash
brew install wkhtmltopdf
```

### خطای encoding
اطمینان حاصل کنید که فایل‌های ورودی با encoding UTF-8 ذخیره شده‌اند.

### خطای template
اگر template کار نمی‌کند، از `--create-templates` استفاده کنید.

## ساختار پروژه

```
core/
├── convert_md_to_formats.py    # اسکریپت اصلی
├── cleaner.lua                 # فیلتر Lua برای تمیز کردن
├── clean_markdown.py           # اسکریپت Python برای تمیز کردن
└── convert_docx_to_clean_md.sh # اسکریپت تبدیل Word به Markdown

output/                         # فایل‌های خروجی
├── book_clean.md              # فایل Markdown
├── book_clean.docx            # فایل Word
└── book_clean.html            # فایل HTML

template.css                    # استایل پیش‌فرض HTML
template.docx                   # template پیش‌فرض DOCX
```

## مشارکت

برای مشارکت در پروژه:
1. Fork کنید
2. Branch جدید ایجاد کنید
3. تغییرات خود را commit کنید
4. Pull Request ارسال کنید

## مجوز

این پروژه تحت مجوز MIT منتشر شده است.

## پشتیبانی

در صورت بروز مشکل یا سوال، لطفاً issue جدید ایجاد کنید. # Md-Generation
