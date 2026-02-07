# Skills Extraction Process

## Overview

The skills extraction system uses a taxonomy-based approach to identify technical skills, soft skills, and certifications from job descriptions. It normalizes variations and synonyms to canonical skill names for consistent analysis.

## How the Taxonomy Works

The taxonomy is stored in `/lib/skills_taxonomy.json` and organized into five categories:

### 1. programming_languages
Core programming languages (JavaScript, Python, Go, etc.)

### 2. frameworks_tools
Development frameworks and DevOps tools (React, Docker, Kubernetes, etc.)

### 3. data_ai
Data science and AI/ML technologies (TensorFlow, Pandas, Machine Learning, etc.)

### 4. soft_skills
Non-technical abilities (Communication, Leadership, Teamwork, etc.)

### 5. certifications
Professional certifications (AWS Certified, PMP, CISSP, etc.)

### Structure

Each category contains a `synonyms` object where:
- **Key**: The canonical skill name (used in output)
- **Value**: Array of alternative names, abbreviations, and translations

Example:
```json
{
  "programming_languages": {
    "synonyms": {
      "JavaScript": ["JS", "javascript", "Javascript"],
      "Python": ["python", "Python3", "py"]
    }
  }
}
```

## Extraction Process

The extraction script (`/lib/extract_skills.sh`) works as follows:

1. **Input**: Receives job description text as argument or stdin
2. **Iteration**: Loops through all categories and skills in taxonomy
3. **Matching**: For each skill, checks if the canonical name or any synonym appears in the description (case-insensitive)
4. **Normalization**: When a match is found, records the canonical skill name
5. **Deduplication**: Removes duplicate matches
6. **Output**: Returns JSON array of unique skills found

### Usage

```bash
# From command line argument
./extract_skills.sh "Looking for Python developer with Docker experience"

# From file
cat job_description.txt | ./extract_skills.sh

# Output example
["Python","Docker"]
```

### Integration with Layers

The extraction script is called by Layer fetch scripts to enrich job postings:

```bash
SKILLS=$(echo "$DESCRIPTION" | "$PROJECT_ROOT/lib/extract_skills.sh")
```

The extracted skills are then included in the JSONL output for downstream processing.

## How to Add New Skills

### Step 1: Identify the Category

Determine which category the skill belongs to:
- Technical/programming? → `programming_languages` or `frameworks_tools`
- Data/AI related? → `data_ai`
- Non-technical? → `soft_skills`
- Professional credential? → `certifications`

### Step 2: Choose the Canonical Name

Select the most widely recognized form as the canonical name. This is what will appear in extraction results.

### Step 3: List All Synonyms

Include:
- Common abbreviations (e.g., "JS" for JavaScript)
- Alternative spellings (e.g., "Golang" for Go)
- Case variations (e.g., "kubernetes", "Kubernetes")
- Related terms (e.g., "containers" for Docker)
- Translations (e.g., "機器學習" for Machine Learning)

### Step 4: Edit the Taxonomy File

```json
{
  "category_name": {
    "synonyms": {
      "Canonical Name": ["synonym1", "synonym2", "abbreviation"]
    }
  }
}
```

### Example: Adding "Svelte"

```json
{
  "frameworks_tools": {
    "synonyms": {
      "Svelte": ["svelte", "SvelteJS", "Svelte.js"]
    }
  }
}
```

### Step 5: Test the Change

```bash
echo "We need a Svelte developer" | ./lib/extract_skills.sh
# Expected output: ["Svelte"]
```

## Limitations and Known Issues

### 1. False Positives

**Issue**: Common words may trigger matches
- Example: "Go" (language) vs "go to market"
- Example: "Lead" (verb) vs "Leadership" (skill)

**Mitigation**: Use word boundaries or context-aware matching in future versions

### 2. Compound Skills

**Issue**: Multi-word skills may be partially matched
- Example: "Machine Learning Engineer" may only match "Machine Learning"

**Mitigation**: Order taxonomy from most specific to least specific

### 3. Context-Dependent Synonyms

**Issue**: Some synonyms are ambiguous
- Example: "PM" could mean "Product Manager" or "Project Management"

**Mitigation**: Include both interpretations or use context rules

### 4. Language Mixing

**Issue**: Bilingual job descriptions may use mixed terminology
- Example: "Python 程式設計" (Python programming)

**Mitigation**: Include translations in synonym lists

### 5. Version-Specific Skills

**Issue**: Skills with version numbers may not match
- Example: "Python 3.9" vs "Python"

**Mitigation**: Strip version numbers in preprocessing or include common versions

### 6. Case Sensitivity

**Issue**: grep -i is case-insensitive, but may miss certain patterns

**Mitigation**: Include multiple case variations in synonyms

### 7. Performance with Large Taxonomies

**Issue**: Script performance degrades with very large taxonomies

**Mitigation**: Consider moving to a more efficient language (Python/Node.js) for production use

## Future Enhancements

1. **Regex-based matching**: Support pattern-based extraction (e.g., "3+ years of X")
2. **Skill clustering**: Group related skills (e.g., all AWS services)
3. **Proficiency level extraction**: Detect skill level mentions (beginner, expert, etc.)
4. **Context awareness**: Use NLP to distinguish between different meanings
5. **Automatic synonym discovery**: Learn new synonyms from data
6. **Skill relationships**: Model prerequisites and related skills

## Maintenance Guidelines

### When to Update the Taxonomy

- New technology becomes mainstream (e.g., new programming language)
- Common synonym patterns emerge in job descriptions
- False positives are frequently observed
- Coverage analysis shows missing skills

### Quarterly Review Process

1. Run coverage analysis on recent job descriptions
2. Identify top unmapped skills
3. Review false positive reports
4. Update taxonomy with community input
5. Test changes against historical data
6. Document changes in git commit

### Version Control

The taxonomy file is version-controlled. When making changes:
1. Create a feature branch
2. Update taxonomy
3. Test with sample job descriptions
4. Submit pull request with rationale
5. Tag releases for major taxonomy updates

## Related Documentation

- Layer CLAUDE.md files: Define how skills are used in each Layer
- `/lib/rss.sh`: RSS parsing utilities
- `/docs/explored.md`: Data source inventory
