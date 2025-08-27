# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll portfolio website project. The directory is currently empty and ready for Jekyll site initialization.

## Common Commands

### Jekyll Setup and Development
```bash
# Initialize a new Jekyll site
bundle exec jekyll new . --force

# Install dependencies
bundle install

# Serve the site locally with live reload
bundle exec jekyll serve
# Alternative with specific options
bundle exec jekyll serve --livereload --port 4000

# Build the site for production
bundle exec jekyll build

# Build with specific environment
JEKYLL_ENV=production bundle exec jekyll build
```

### Ruby/Bundler Management
```bash
# Install Ruby gems
bundle install

# Update gems
bundle update

# Check for outdated gems
bundle outdated
```

## Architecture Notes

### Expected Jekyll Structure
Once initialized, the project will follow standard Jekyll conventions:
- `_config.yml` - Main configuration file
- `_posts/` - Blog posts in Markdown
- `_layouts/` - HTML templates
- `_includes/` - Reusable HTML snippets
- `_sass/` - Sass stylesheets
- `assets/` - Static files (CSS, JS, images)
- `_site/` - Generated site (not committed to git)

### Portfolio-Specific Considerations
- This is intended as a portfolio site, so expect sections for projects, about, contact
- Likely to use Jekyll collections for portfolio items
- May include custom layouts for project showcases
- Consider responsive design and accessibility

## Development Notes

### Local Development
- Default Jekyll development server runs on `http://localhost:4000`
- Changes to `_config.yml` require server restart
- Other changes reload automatically with `--livereload` flag

### Common File Patterns
- Posts: `_posts/YYYY-MM-DD-title.md`
- Portfolio items: `_portfolio/project-name.md` (if using collections)
- Pages: `page-name.md` or `page-name/index.md`

### Git Considerations
- Add `_site/` to `.gitignore` (generated content)
- Add `.jekyll-cache/` to `.gitignore`
- Include `Gemfile.lock` in version control
- always document your steps in an easy to follow guide for learning purpose