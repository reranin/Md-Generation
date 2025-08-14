-- حذف TOC های Word، span و {#…} - نسخه v5
-- بهبود یافته برای پردازش بهتر فایل‌های Word

-- تنظیمات پیش‌فرض
local config = {
  remove_toc_links = true,
  remove_span_tags = true,
  remove_identifiers = true,
  remove_classes = true,
  remove_attributes = true,
  clean_headers = true,
  clean_paragraphs = true,
  clean_links = true,
  verbose = false
}

-- تابع کمکی برای لاگ
local function log(message)
  if config.verbose then
    io.stderr:write("[cleaner] " .. message .. "\n")
  end
end

-- تابع برای حذف لینک‌های تودرتو
local function remove_nested_links(text)
  local cleaned = text
  local previous = ""
  
  -- تکرار تا زمانی که تغییری رخ ندهد
  while cleaned ~= previous do
    previous = cleaned
    -- حذف لینک‌های ساده
    cleaned = cleaned:gsub("%[([^%]]+)%]%(%#[^%)]+%)", "%1")
    -- حذف لینک‌های تودرتو پیچیده
    cleaned = cleaned:gsub("%[([^%]]+)%]%(%#[^%)]+%)", "%1")
    -- حذف لینک‌های با الگوی خاص
    cleaned = cleaned:gsub("%[([^%]]+)%]%(%#[^%)]+%)", "%1")
  end
  
  -- حذف لینک‌های باقی‌مانده با الگوی خاص
  cleaned = cleaned:gsub("%[([^%]]+)%]%(%#[^%)]+%)", "%1")
  cleaned = cleaned:gsub("%[([^%]]+)%]%(%#[^%)]+%)", "%1")
  
  return cleaned
end

-- تابع اصلی برای تمیز کردن متن
local function clean_text(text)
  if not text or type(text) ~= "string" then
    return text
  end
  
  local cleaned = text
  
  -- حذف {#…} - شناسه‌ها
  if config.remove_identifiers then
    cleaned = cleaned:gsub("{#[^}]*}", "")
    log("حذف شناسه‌ها از متن")
  end
  
  -- حذف تگ‌های span HTML
  if config.remove_span_tags then
    cleaned = cleaned:gsub("<span[^>]*>", "")
    cleaned = cleaned:gsub("</span>", "")
    log("حذف تگ‌های span")
  end
  
  -- حذف لینک‌های TOC مثل [15](#_Toc…)
  if config.remove_toc_links then
    cleaned = cleaned:gsub("%[%d+%]%(%#_Toc[%d]+%)", "")
    cleaned = cleaned:gsub("%[%d+%]%(%#_Ref[%d]+%)", "")
    log("حذف لینک‌های TOC")
  end
  
  -- حذف لینک‌های تودرتو با تابع مخصوص
  cleaned = remove_nested_links(cleaned)
  
  -- حذف براکت‌های باز که بسته نشده‌اند
  cleaned = cleaned:gsub("%[[^%]]*%d*%[?", "")
  
  return cleaned
end

-- پردازش عناصر Str
function Str(el)
  if not config.clean_paragraphs then
    return el
  end
  
  local cleaned_text = clean_text(el.text)
  if cleaned_text ~= el.text then
    log("تمیز کردن متن Str")
    return pandoc.Str(cleaned_text)
  end
  return el
end

-- پردازش عناصر Header
function Header(el)
  if not config.clean_headers then
    return el
  end
  
  local modified = false
  
  -- حذف شناسه
  if config.remove_identifiers and el.identifier and el.identifier ~= "" then
    el.identifier = ""
    modified = true
    log("حذف شناسه از Header")
  end
  
  -- حذف کلاس‌ها
  if config.remove_classes and #el.classes > 0 then
    el.classes = {}
    modified = true
    log("حذف کلاس‌ها از Header")
  end
  
  -- حذف ویژگی‌ها
  if config.remove_attributes and el.attributes and #el.attributes > 0 then
    el.attributes = {}
    modified = true
    log("حذف ویژگی‌ها از Header")
  end
  
  -- تمیز کردن محتوای Header
  if config.clean_paragraphs then
    for i, item in ipairs(el.content) do
      if item.t == "Str" then
        local cleaned = clean_text(item.text)
        if cleaned ~= item.text then
          el.content[i] = pandoc.Str(cleaned)
          modified = true
        end
      end
    end
  end
  
  if modified then
    log("Header تمیز شد")
  end
  
  return el
end

-- پردازش عناصر Para
function Para(el)
  if not config.clean_paragraphs then
    return el
  end
  
  local new_content = {}
  local modified = false
  
  for _, item in pairs(el.content) do
    if item.t == "Str" then
      local cleaned_text = clean_text(item.text)
      if cleaned_text ~= item.text then
        table.insert(new_content, pandoc.Str(cleaned_text))
        modified = true
      else
        table.insert(new_content, item)
      end
    elseif item.t == "Link" and config.clean_links then
      -- حذف لینک‌های TOC
      if item.target:match("^#_Toc") or item.target:match("^#_Ref") then
        for _, subitem in pairs(item.content) do
          table.insert(new_content, subitem)
        end
        modified = true
        log("حذف لینک TOC")
      else
        table.insert(new_content, item)
      end
    else
      table.insert(new_content, item)
    end
  end
  
  if modified then
    log("Paragraphe تمیز شد")
    return pandoc.Para(new_content)
  end
  
  return el
end

-- پردازش عناصر Link
function Link(el)
  if not config.clean_links then
    return el
  end
  
  -- حذف لینک‌های TOC
  if el.target:match("^#_Toc") or el.target:match("^#_Ref") then
    log("حذف لینک TOC کامل")
    return el.content
  end
  
  return el
end

-- پردازش عناصر Div
function Div(el)
  -- حذف کلاس‌ها و شناسه‌های مشکوک
  if config.remove_classes and #el.classes > 0 then
    local has_suspicious_class = false
    for _, class in ipairs(el.classes) do
      if class:match("^TOC") or class:match("^toc") or class:match("^TableOfContents") then
        has_suspicious_class = true
        break
      end
    end
    
    if has_suspicious_class then
      log("حذف Div با کلاس TOC")
      return el.content
    end
  end
  
  return el
end

-- پردازش عناصر Span
function Span(el)
  -- حذف تمام Span ها و فقط محتوای آنها را نگه دار
  if config.remove_span_tags then
    log("حذف Span و نگه داشتن محتوا")
    return el.content
  end
  
  return el
end

-- تابع راه‌اندازی
function Pandoc(doc)
  log("شروع پردازش فایل با cleaner")
  
  -- تنظیم متا داده‌ها
  if doc.meta and doc.meta.toc then
    doc.meta.toc = nil
    log("حذف TOC از متا داده‌ها")
  end
  
  return doc
end

log("فیلتر cleaner بارگذاری شد") 