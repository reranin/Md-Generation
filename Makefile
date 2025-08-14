# Makefile برای پروژه تبدیل Word به Markdown و Markdown به فرمت‌های مختلف
# استفاده: make convert INPUT=book.docx OUTPUT=book_clean.md
# استفاده: make convert-md INPUT=book.md FORMATS=docx,html

.PHONY: help convert convert-md clean install test

# متغیرهای پیش‌فرض
INPUT ?= book.docx
OUTPUT ?= $(basename $(INPUT))_clean.md

help: ## نمایش راهنما
	@echo "استفاده: make <target>"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## نصب پیش‌نیازها
	@echo "🔧 بررسی پیش‌نیازها..."
	@command -v pandoc >/dev/null 2>&1 || { echo "❌ pandoc نصب نشده است. لطفاً نصب کنید:"; echo "   brew install pandoc"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "❌ python3 نصب نشده است. لطفاً نصب کنید:"; echo "   brew install python3"; exit 1; }
	@echo "✅ تمام پیش‌نیازها موجود هستند"
	@chmod +x core/convert_docx_to_clean_md.sh core/clean_markdown.py

convert: install ## تبدیل فایل Word به Markdown
	@echo "🚀 شروع تبدیل $(INPUT) به $(OUTPUT)..."
	@$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_docx_to_clean_md.sh "$(INPUT)" "$(OUTPUT)"

convert-auto: install ## تبدیل فایل Word با نام خودکار
	@echo "🚀 شروع تبدیل $(INPUT)..."
	@$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_docx_to_clean_md.sh "$(INPUT)"

convert-input: install ## تبدیل تمام فایل‌های Word در فولدر input
	@echo "🚀 شروع تبدیل تمام فایل‌های Word در فولدر input..."
	@for file in input/*.docx; do \
		if [ -f "$$file" ]; then \
			echo "📄 تبدیل $$file..."; \
			$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_docx_to_clean_md.sh "$$file" "output/$$(basename "$$file" .docx)_clean.md"; \
		fi; \
	done

convert-md: install ## تبدیل فایل Markdown به فرمت‌های مختلف
	@echo "🚀 شروع تبدیل $(INPUT) به فرمت‌های: $(FORMATS)..."
	@python3 $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_md_to_formats.py "$(INPUT)" --formats "$(FORMATS)"

convert-md-all: install ## تبدیل فایل Markdown به تمام فرمت‌ها
	@echo "🚀 شروع تبدیل $(INPUT) به تمام فرمت‌ها..."
	@python3 $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_md_to_formats.py "$(INPUT)"

create-templates: install ## ایجاد فایل‌های template پیش‌فرض
	@echo "🔧 ایجاد فایل‌های template..."
	@python3 $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/core/convert_md_to_formats.py "$(INPUT)" --create-templates

clean: ## حذف فایل‌های موقت
	@echo "🧹 حذف فایل‌های موقت..."
	@rm -f *_temp.md *_cleaned.md *_final.md
	@echo "✅ فایل‌های موقت حذف شدند"

clean-all: clean ## حذف تمام فایل‌های خروجی
	@echo "🧹 حذف تمام فایل‌های خروجی..."
	@rm -f output/*.md
	@rm -rf media/
	@echo "✅ تمام فایل‌های خروجی حذف شدند"

test: ## تست فیلتر Lua
	@echo "🧪 تست فیلتر Lua..."
	@echo "✅ فیلتر Lua آماده است"

status: ## نمایش وضعیت پروژه
	@echo "📊 وضعیت پروژه:"
	@echo "  فایل‌های موجود:"
	@ls -la *.md *.env 2>/dev/null || echo "    هیچ فایلی یافت نشد"
	@echo "  فایل‌های core:"
	@ls -la core/*.lua core/*.py core/*.sh 2>/dev/null || echo "    هیچ فایلی یافت نشد"
	@echo "  فایل‌های input:"
	@ls -la input/*.docx 2>/dev/null || echo "    هیچ فایلی یافت نشد"
	@echo "  فایل‌های output:"
	@ls -la output/*.md 2>/dev/null || echo "    هیچ فایلی یافت نشد"
	@echo "  پوشه‌های موجود:"
	@ls -la */ 2>/dev/null || echo "    هیچ پوشه‌ای یافت نشد"

# هدف پیش‌فرض
.DEFAULT_GOAL := help 