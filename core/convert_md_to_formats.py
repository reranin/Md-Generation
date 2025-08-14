#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
تبدیل‌کننده Markdown به فرمت‌های مختلف
تبدیل فایل‌های .md به DOCX، HTML، PDF
"""

import os
import sys
import argparse
import subprocess
import platform
from pathlib import Path
import re

class MarkdownConverter:
    def __init__(self):
        self.supported_formats = ['docx', 'html', 'pdf']
        self.temp_files = []
        
    def check_dependencies(self):
        """بررسی پیش‌نیازها"""
        print("🔧 بررسی پیش‌نیازها...")
        
        # بررسی pandoc
        try:
            result = subprocess.run(['pandoc', '--version'], 
                                  capture_output=True, text=True, check=True)
            print("✅ Pandoc موجود است")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("❌ Pandoc نصب نشده است")
            print("   برای نصب: brew install pandoc (macOS)")
            return False
        
        # بررسی wkhtmltopdf برای PDF
        try:
            result = subprocess.run(['wkhtmltopdf', '--version'], 
                                  capture_output=True, text=True, check=True)
            print("✅ wkhtmltopdf موجود است")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("⚠️  wkhtmltopdf نصب نشده است (برای PDF)")
            print("   برای نصب: brew install wkhtmltopdf (macOS)")
        
        return True
    
    def convert_md_to_docx(self, input_file, output_file, template=None):
        """تبدیل Markdown به DOCX"""
        print(f"📝 تبدیل {input_file} به DOCX...")
        
        cmd = [
            'pandoc',
            input_file,
            '-o', output_file,
            '--from', 'markdown',
            '--to', 'docx',
            '--wrap', 'none'
        ]
        
        if template:
            cmd.extend(['--reference-doc', template])
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(f"✅ تبدیل DOCX با موفقیت انجام شد: {output_file}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ خطا در تبدیل DOCX: {e}")
            return False
    
    def convert_md_to_html(self, input_file, output_file, css_template=None):
        """تبدیل Markdown به HTML"""
        print(f"🌐 تبدیل {input_file} به HTML...")
        
        cmd = [
            'pandoc',
            input_file,
            '-o', output_file,
            '--from', 'markdown',
            '--to', 'html5',
            '--standalone',
            '--wrap', 'none',
            '--toc',
            '--toc-depth', '3'
        ]
        
        if css_template:
            cmd.extend(['--css', css_template])
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(f"✅ تبدیل HTML با موفقیت انجام شد: {output_file}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ خطا در تبدیل HTML: {e}")
            return False
    
    def convert_md_to_pdf(self, input_file, output_file, template=None):
        """تبدیل Markdown به PDF"""
        print(f"📄 تبدیل {input_file} به PDF...")
        
        # ابتدا به HTML تبدیل می‌کنیم
        temp_html = f"{input_file}_temp.html"
        self.temp_files.append(temp_html)
        
        if not self.convert_md_to_html(input_file, temp_html):
            return False
        
        # سپس HTML را به PDF تبدیل می‌کنیم
        try:
            cmd = [
                'wkhtmltopdf',
                '--page-size', 'A4',
                '--margin-top', '20mm',
                '--margin-right', '20mm',
                '--margin-bottom', '20mm',
                '--margin-left', '20mm',
                '--encoding', 'UTF-8',
                temp_html,
                output_file
            ]
            
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(f"✅ تبدیل PDF با موفقیت انجام شد: {output_file}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ خطا در تبدیل PDF: {e}")
            return False
    
    def create_css_template(self, output_file):
        """ایجاد فایل CSS پیش‌فرض"""
        css_content = """/* استایل پیش‌فرض برای HTML */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 20px;
    background-color: #f8f9fa;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    background-color: white;
    padding: 40px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

h1, h2, h3, h4, h5, h6 {
    color: #2c3e50;
    margin-top: 30px;
    margin-bottom: 15px;
}

h1 { font-size: 2.5em; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
h2 { font-size: 2em; border-bottom: 2px solid #e74c3c; padding-bottom: 8px; }
h3 { font-size: 1.5em; color: #8e44ad; }

p {
    margin-bottom: 15px;
    text-align: justify;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 12px;
    text-align: right;
}

th {
    background-color: #3498db;
    color: white;
    font-weight: bold;
}

tr:nth-child(even) {
    background-color: #f2f2f2;
}

img {
    max-width: 100%;
    height: auto;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
}

blockquote {
    border-left: 4px solid #3498db;
    margin: 20px 0;
    padding: 10px 20px;
    background-color: #ecf0f1;
    font-style: italic;
}

code {
    background-color: #f8f9fa;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'Courier New', monospace;
}

pre {
    background-color: #2c3e50;
    color: #ecf0f1;
    padding: 20px;
    border-radius: 5px;
    overflow-x: auto;
}

.toc {
    background-color: #ecf0f1;
    padding: 20px;
    border-radius: 5px;
    margin-bottom: 30px;
}

.toc h2 {
    margin-top: 0;
    color: #2c3e50;
}

.toc ul {
    list-style-type: none;
    padding-left: 0;
}

.toc li {
    margin: 8px 0;
}

.toc a {
    text-decoration: none;
    color: #3498db;
}

.toc a:hover {
    text-decoration: underline;
}
"""
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(css_content)
        
        print(f"✅ فایل CSS ایجاد شد: {output_file}")
    
    def create_docx_template(self, output_file):
        """ایجاد فایل DOCX template پیش‌فرض"""
        print("📋 ایجاد template DOCX...")
        
        # ایجاد یک فایل Markdown ساده برای template
        template_md = """# Template Document

این یک فایل template برای تبدیل Markdown به DOCX است.

## ویژگی‌ها
- فونت‌های استاندارد
- استایل‌های پیش‌فرض
- قابلیت شخصی‌سازی

## استفاده
از این فایل به عنوان reference-doc استفاده کنید.
"""
        
        temp_md = f"{output_file}_temp.md"
        self.temp_files.append(temp_md)
        
        with open(temp_md, 'w', encoding='utf-8') as f:
            f.write(template_md)
        
        # تبدیل به DOCX
        if self.convert_md_to_docx(temp_md, output_file):
            print(f"✅ Template DOCX ایجاد شد: {output_file}")
            return True
        else:
            print("❌ خطا در ایجاد template DOCX")
            return False
    
    def convert_all_formats(self, input_file, output_dir, formats=None):
        """تبدیل به تمام فرمت‌های درخواستی"""
        if formats is None:
            formats = self.supported_formats
        
        input_path = Path(input_file)
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True)
        
        print(f"🚀 شروع تبدیل {input_file} به فرمت‌های: {', '.join(formats)}")
        
        results = {}
        
        for fmt in formats:
            if fmt not in self.supported_formats:
                print(f"⚠️  فرمت {fmt} پشتیبانی نمی‌شود")
                continue
            
            output_file = output_path / f"{input_path.stem}.{fmt}"
            
            if fmt == 'docx':
                results[fmt] = self.convert_md_to_docx(input_file, str(output_file))
            elif fmt == 'html':
                results[fmt] = self.convert_md_to_html(input_file, str(output_file))
            elif fmt == 'pdf':
                results[fmt] = self.convert_md_to_pdf(input_file, str(output_file))
        
        return results
    
    def cleanup_temp_files(self):
        """حذف فایل‌های موقت"""
        for temp_file in self.temp_files:
            try:
                if os.path.exists(temp_file):
                    os.remove(temp_file)
                    print(f"🧹 فایل موقت حذف شد: {temp_file}")
            except Exception as e:
                print(f"⚠️  خطا در حذف فایل موقت {temp_file}: {e}")
        
        self.temp_files.clear()

def main():
    parser = argparse.ArgumentParser(
        description='تبدیل فایل Markdown به فرمت‌های مختلف',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
نمونه‌های استفاده:
  python3 convert_md_to_formats.py input.md --formats docx,html,pdf
  python3 convert_md_to_formats.py input.md --output-dir output --formats docx
  python3 convert_md_to_formats.py input.md --create-templates
        """
    )
    
    parser.add_argument('input_file', help='فایل Markdown ورودی')
    parser.add_argument('-o', '--output-dir', default='output', 
                       help='پوشه خروجی (پیش‌فرض: output)')
    parser.add_argument('-f', '--formats', default='docx,html,pdf',
                       help='فرمت‌های خروجی (پیش‌فرض: docx,html,pdf)')
    parser.add_argument('--create-templates', action='store_true',
                       help='ایجاد فایل‌های template پیش‌فرض')
    parser.add_argument('--css-template', help='فایل CSS برای HTML')
    parser.add_argument('--docx-template', help='فایل DOCX template')
    
    args = parser.parse_args()
    
    # بررسی وجود فایل ورودی
    if not os.path.exists(args.input_file):
        print(f"❌ فایل {args.input_file} یافت نشد")
        sys.exit(1)
    
    # ایجاد converter
    converter = MarkdownConverter()
    
    # بررسی پیش‌نیازها
    if not converter.check_dependencies():
        sys.exit(1)
    
    # ایجاد template ها در صورت درخواست
    if args.create_templates:
        print("🔧 ایجاد فایل‌های template...")
        converter.create_css_template('template.css')
        converter.create_docx_template('template.docx')
        print("✅ فایل‌های template ایجاد شدند")
    
    # تبدیل فایل
    formats = [f.strip() for f in args.formats.split(',')]
    results = converter.convert_all_formats(args.input_file, args.output_dir, formats)
    
    # نمایش نتایج
    print("\n📊 خلاصه نتایج:")
    for fmt, success in results.items():
        status = "✅ موفق" if success else "❌ ناموفق"
        print(f"  {fmt.upper()}: {status}")
    
    # حذف فایل‌های موقت
    converter.cleanup_temp_files()
    
    print("\n🎉 عملیات تمام شد!")

if __name__ == '__main__':
    main() 