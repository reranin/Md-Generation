#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
اسکریپت تمیز کردن نهایی فایل Markdown
حذف لینک‌های تودرتو و عناصر ناخواسته باقی‌مانده
"""

import re
import sys
from pathlib import Path

def clean_nested_links(text):
    """حذف لینک‌های تودرتو"""
    cleaned = text
    previous = ""
    
    # تکرار تا زمانی که تغییری رخ ندهد
    while cleaned != previous:
        previous = cleaned
        # حذف لینک‌های Markdown
        cleaned = re.sub(r'\[([^\]]+)\]\(#[^)]+\)', r'\1', cleaned)
    
    return cleaned

def clean_markdown_file(input_file, output_file):
    """تمیز کردن فایل Markdown"""
    try:
        # خواندن فایل
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        print(f"📖 خواندن فایل: {input_file}")
        
        # تمیز کردن لینک‌های تودرتو
        cleaned_content = clean_nested_links(content)
        
        # حذف سایر عناصر ناخواسته
        # حذف لینک‌های باقی‌مانده
        cleaned_content = re.sub(r'\[([^\]]+)\]\(#[^)]+\)', r'\1', cleaned_content)
        
        # حذف براکت‌های اضافی
        cleaned_content = re.sub(r'\[([^\]]+)\]\[([^\]]+)\]', r'\1 \2', cleaned_content)
        
        # حذف لینک‌های خالی
        cleaned_content = re.sub(r'\[\]\([^)]+\)', '', cleaned_content)
        
        # ذخیره فایل تمیز شده
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(cleaned_content)
        
        print(f"✅ فایل تمیز شده در: {output_file}")
        return True
        
    except Exception as e:
        print(f"❌ خطا در پردازش فایل: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("استفاده: python clean_markdown.py <فایل_ورودی> [فایل_خروجی]")
        print("مثال: python clean_markdown.py book_final.md book_clean.md")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else f"{Path(input_file).stem}_clean.md"
    
    if not Path(input_file).exists():
        print(f"❌ فایل ورودی '{input_file}' یافت نشد!")
        sys.exit(1)
    
    print("🧹 شروع تمیز کردن فایل Markdown...")
    
    if clean_markdown_file(input_file, output_file):
        print("🎉 عملیات تمیز کردن با موفقیت انجام شد!")
    else:
        print("💥 خطا در عملیات تمیز کردن!")
        sys.exit(1)

if __name__ == "__main__":
    main() 