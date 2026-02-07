# Job Role Mapping System

## Overview

This system provides a comprehensive mapping of job titles to 53 predefined job roles, categorized by industry and AI replacement risk vectors. It enables automated analysis of job market trends and AI impact on different occupations.

## Files

- **job_roles.json** - Master data file containing all 53 job roles with metadata
- **match_role.sh** - Script to match job titles to predefined roles
- **list_roles.sh** - Script to list and analyze all roles

## Job Role Structure

Each role contains:
- `id`: Unique identifier (1-53)
- `name_en`: English name
- `name_zh`: Chinese name
- `industry`: Industry category
- `ai_vector`: AI replacement vector (see below)
- `keywords`: List of keywords for matching

## AI Replacement Vectors

The system categorizes roles into 5 AI replacement vectors based on task characteristics:

### 1. cognitive_routine (Risk: HIGH)
**認知例行工作 - 可程式化的腦力工作**

Routine cognitive tasks that can be easily programmed and automated.

**Examples:** Data entry, basic accounting, customer service scripts

**Roles (8):**
- Data Analyst (資料分析師)
- Customer Service (客服專員)
- Accountant (會計師)
- Administrative Assistant (行政助理)
- Quality Control (品管人員)
- QA Engineer (測試工程師)
- Medical Technician (醫檢師)
- Bank Teller (銀行櫃員)

### 2. cognitive_nonroutine (Risk: MEDIUM)
**認知非例行工作 - 需要判斷和創造力**

Non-routine cognitive work requiring judgment, creativity, and complex decision-making.

**Examples:** Strategic planning, research analysis, design work

**Roles (26):**
- Software Engineer (軟體工程師)
- Data Scientist (資料科學家)
- Frontend/Backend Engineers (前端/後端工程師)
- Product Manager (產品經理)
- UI/UX Designer (UI/UX設計師)
- Marketing Specialist (行銷專員)
- And 20 more...

### 3. physical_routine (Risk: HIGH)
**體力例行工作 - 重複性體力勞動**

Repetitive physical labor that follows predictable patterns.

**Examples:** Assembly line work, warehouse operations, packaging

**Roles (4):**
- Manufacturing Operator (生產線作業員)
- Warehouse Worker (倉儲人員)
- Delivery Driver (配送司機)
- Security Guard (保全人員)

### 4. physical_nonroutine (Risk: LOW)
**體力非例行工作 - 需要靈活應變的體力工作**

Physical work requiring adaptability and problem-solving in varied environments.

**Examples:** Equipment repair, on-site construction, healthcare

**Roles (8):**
- Nurse (護理師)
- Construction Worker (營建工人)
- Chef (廚師)
- Caregiver (照護員)
- Electrician (電工)
- Plumber (水管工)
- Mechanic (技工)
- Farmer (農民)

### 5. interpersonal (Risk: LOW)
**人際互動工作 - 高度依賴人際溝通**

Work heavily dependent on human interaction and relationship building.

**Examples:** Sales, counseling, teaching

**Roles (7):**
- Sales Representative (業務代表)
- HR Specialist (人資專員)
- Teacher (教師)
- Social Worker (社工人員)
- Insurance Agent (保險業務員)
- Retail Staff (門市人員)
- Store Manager (店長)

## Industry Categories

The system covers 14 major industries:

1. **tech** - Technology and software
2. **finance** - Banking, insurance, accounting
3. **healthcare** - Medical and healthcare services
4. **education** - Teaching and training
5. **creative** - Design, media, arts
6. **retail_service** - Retail and service industry
7. **manufacturing** - Production and assembly
8. **construction** - Building and civil engineering
9. **logistics** - Transportation and warehousing
10. **professional** - Professional services and consulting
11. **legal** - Legal services
12. **care** - Social work and caregiving
13. **agriculture** - Farming and agricultural technology
14. **management** - Executive and management roles
15. **skilled_trade** - Skilled trades (electrician, plumber, mechanic)

## Usage

### Matching a Job Title

```bash
./lib/match_role.sh "前端工程師"
```

**Output:**
```json
{
  "matched": true,
  "score": 1520,
  "role": {
    "id": 4,
    "name_en": "Frontend Engineer",
    "name_zh": "前端工程師",
    "industry": "tech",
    "ai_vector": "cognitive_nonroutine",
    "ai_vector_description": "認知非例行工作 - 需要判斷和創造力",
    "ai_risk_level": "medium"
  },
  "input": "前端工程師"
}
```

### Listing All Roles

```bash
# List all roles with details
./lib/list_roles.sh

# Group by AI vector
./lib/list_roles.sh --by-vector

# Group by industry
./lib/list_roles.sh --by-industry

# Show summary statistics
./lib/list_roles.sh --summary
```

## Matching Algorithm

The matching algorithm uses a weighted scoring system:

1. **Exact match** (1000 points): Job title exactly matches a keyword
2. **Contains match** (keyword_length × 10 points): Job title contains the keyword
3. **Partial match** (title_length × 5 points): Keyword contains the job title
4. **Bonus** (500 points): Added if the best keyword match score exceeds 500

The role with the highest total score is returned. Longer keywords receive higher scores to prioritize more specific matches.

## Examples

### Example 1: Exact Match
```bash
./lib/match_role.sh "軟體工程師"
# Returns: Software Engineer (id: 1) with high confidence
```

### Example 2: Fuzzy Match
```bash
./lib/match_role.sh "前端開發"
# Returns: Frontend Engineer (id: 4) based on "前端" keyword
```

### Example 3: English Title
```bash
./lib/match_role.sh "devops engineer"
# Returns: DevOps Engineer (id: 6)
```

### Example 4: Abbreviation
```bash
./lib/match_role.sh "PM"
# Returns: Product Manager (id: 7)
```

### Example 5: No Match
```bash
./lib/match_role.sh "太空人"
# Returns: matched: false with suggestion message
```

## Integration with Other Systems

### Use in Layer Extraction

When extracting job market data, use `match_role.sh` to normalize job titles:

```bash
# In a Layer's extraction script
JOB_TITLE=$(echo "$json_line" | jq -r '.title')
ROLE_INFO=$(./lib/match_role.sh "$JOB_TITLE")

if [[ $(echo "$ROLE_INFO" | jq -r '.matched') == "true" ]]; then
    ROLE_ID=$(echo "$ROLE_INFO" | jq -r '.role.id')
    AI_VECTOR=$(echo "$ROLE_INFO" | jq -r '.role.ai_vector')
    # Use in your extraction...
fi
```

### Use in Narrator Analysis

When generating reports, aggregate by AI vector:

```bash
# Count roles by AI replacement risk
for vector in cognitive_routine cognitive_nonroutine physical_routine physical_nonroutine interpersonal; do
    count=$(jq "[.roles[] | select(.ai_vector == \"$vector\")] | length" lib/job_roles.json)
    echo "$vector: $count roles"
done
```

## Extending the System

### Adding New Roles

1. Edit `lib/job_roles.json`
2. Add new role to the `roles` array with unique ID
3. Update `metadata.total_roles` count
4. Ensure keywords are comprehensive and include both English and Chinese terms

### Adding Keywords to Existing Roles

Edit the `keywords` array for the target role. Include:
- Exact job title in both languages
- Common variations and abbreviations
- Related technical terms
- Industry-specific jargon

### Best Practices for Keywords

1. **Include exact titles**: Always add the exact Chinese and English names
2. **Add abbreviations**: PM, QA, HR, etc.
3. **Add variations**: "軟體工程師", "軟體", "工程師", "developer"
4. **Be specific**: Longer, more specific keywords get higher priority
5. **Avoid overlap**: Minimize keyword overlap between roles to reduce ambiguity

## Maintenance

### Regular Updates

- Review keyword effectiveness quarterly
- Add new emerging job titles
- Update AI risk assessments based on technology trends
- Validate matching accuracy with real job posting data

### Quality Checks

```bash
# Check for duplicate IDs
jq '.roles[].id' lib/job_roles.json | sort | uniq -d

# Validate JSON structure
jq empty lib/job_roles.json && echo "Valid JSON"

# Check total count
jq '.roles | length' lib/job_roles.json
```

## Dependencies

- **jq** - JSON processor (required)
- **bash** 4.0+ - Shell scripting

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
apt-get install jq

# CentOS/RHEL
yum install jq
```

## License

Part of the Skills Shift Observatory system. Internal use only.
