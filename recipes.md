---
layout: default
title: Receitas
permalink: /recipes/
---

# 📚 Receitas

{% for recipe in site.recipes %}
## [{{ recipe.title }}]({{ recipe.url }})

{% if recipe.servings or recipe.time or recipe.cuisine %}
**Metadados:** 
{% if recipe.servings %}🍽️ {{ recipe.servings }} • {% endif %}
{% if recipe.time %}⏱️ {{ recipe.time }} • {% endif %}
{% if recipe.cuisine %}🌎 {{ recipe.cuisine }}{% endif %}
{% endif %}

[Ver receita →]({{ recipe.url }}) • [📥 Baixar .cook](/assets/recipes/{{ recipe.name | replace: '.md', '.cook' }})

---
{% endfor %}
