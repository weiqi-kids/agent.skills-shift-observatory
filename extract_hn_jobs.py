#!/usr/bin/env python3
import json
import re
import html
import sys
from datetime import datetime
from pathlib import Path

# Category keywords mapping
CATEGORY_KEYWORDS = {
    'backend': ['backend', 'server', 'api', 'go', 'rust', 'python', 'java', 'node.js', 'django', 'flask'],
    'frontend': ['frontend', 'react', 'vue', 'typescript', 'javascript', 'angular', 'ui', 'ux'],
    'fullstack': ['fullstack', 'full-stack', 'full stack'],
    'mobile': ['ios', 'android', 'mobile', 'react native', 'flutter', 'swift', 'kotlin'],
    'devops': ['devops', 'sre', 'infrastructure', 'kubernetes', 'aws', 'cloud', 'docker', 'terraform'],
    'data': ['data engineer', 'data scientist', 'ml', 'ai', 'machine learning', 'mlops', 'analytics'],
    'security': ['security', 'infosec', 'cybersecurity', 'appsec', 'devsecops'],
    'management': ['engineering manager', 'tech lead', 'cto', 'vp', 'head of', 'director']
}

def decode_html(text):
    """Decode HTML entities"""
    return html.unescape(text)

def determine_category(text):
    """Determine job category based on keywords"""
    text_lower = text.lower()

    # Check fullstack first (most specific)
    if any(kw in text_lower for kw in CATEGORY_KEYWORDS['fullstack']):
        return 'fullstack'

    # Check other categories
    for category, keywords in CATEGORY_KEYWORDS.items():
        if category == 'fullstack':
            continue
        if any(kw in text_lower for kw in keywords):
            return category

    return 'other'

def parse_job_posting(item):
    """Parse job posting from HN comment"""
    text = decode_html(item['text'])

    # Try to parse company and position from first line
    # Common format: "Company | Position | Location | ..."
    lines = text.split('\n')
    first_line = lines[0] if lines else text[:200]

    parts = [p.strip() for p in first_line.split('|')]

    company = "Unknown"
    position = "Unknown"
    location = "Unknown"
    salary = ""
    confidence = "中"

    if len(parts) >= 2:
        company = parts[0]
        position = parts[1]
        if len(parts) >= 3:
            location = parts[2]
            confidence = "高"
        else:
            confidence = "中"
    else:
        # Fallback: use first few words as company
        words = first_line.split()
        if words:
            company = words[0]
            if len(words) > 1:
                position = ' '.join(words[1:5])
        confidence = "低"

    # Detect remote
    remote_friendly = 'remote' in text.lower()

    # Extract salary (look for patterns like $100k, $100-150k, etc)
    salary_match = re.search(r'\$[\d,]+(k|K)?(-\$?[\d,]+(k|K)?)?', text)
    if salary_match:
        salary = salary_match.group(0)

    # Determine category
    category = determine_category(text)

    return {
        'company': company,
        'position': position,
        'location': location,
        'salary': salary,
        'remote_friendly': remote_friendly,
        'category': category,
        'confidence': confidence,
        'text': text
    }

def create_markdown(item, parsed):
    """Create markdown content"""
    current_time = datetime.utcnow().isoformat() + 'Z'

    md = f"""---
hn_id: {item['id']}
company: "{parsed['company']}"
position: "{parsed['position']}"
location: "{parsed['location']}"
category: "{parsed['category']}"
remote_friendly: {str(parsed['remote_friendly']).lower()}
salary_range: "{parsed['salary']}"
posted_at: "{item['created_at']}"
source_url: "https://news.ycombinator.com/item?id={item['id']}"
fetched_at: "{current_time}"
source_layer: "global_hn_hiring"
confidence: "{parsed['confidence']}"
---

# {parsed['company']} - {parsed['position']}

## 職位資訊
- **公司**: {parsed['company']}
- **職位**: {parsed['position']}
- **地點**: {parsed['location']}
- **遠端**: {"是" if parsed['remote_friendly'] else "否"}
- **薪資**: {parsed['salary'] if parsed['salary'] else "未揭露"}

## 原始內容
{parsed['text']}

## 來源
https://news.ycombinator.com/item?id={item['id']}
"""
    return md

def process_line(line_num, jsonl_path, output_dir):
    """Process a single line from JSONL"""
    try:
        # Read the specific line
        with open(jsonl_path, 'r') as f:
            for i, line in enumerate(f, 1):
                if i == line_num:
                    item = json.loads(line)
                    break
            else:
                return None

        # Parse the job posting
        parsed = parse_job_posting(item)

        # Create markdown content
        md_content = create_markdown(item, parsed)

        # Write to file
        category = parsed['category']
        output_file = Path(output_dir) / category / f"hn-{item['id']}.md"
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, 'w') as f:
            f.write(md_content)

        return {
            'id': item['id'],
            'category': category,
            'file': str(output_file)
        }

    except Exception as e:
        print(f"Error processing line {line_num}: {e}", file=sys.stderr)
        return None

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: extract_hn_jobs.py <line_num> <jsonl_path> <output_dir>")
        sys.exit(1)

    line_num = int(sys.argv[1])
    jsonl_path = sys.argv[2]
    output_dir = sys.argv[3]

    result = process_line(line_num, jsonl_path, output_dir)
    if result:
        print(json.dumps(result))
    else:
        sys.exit(1)
