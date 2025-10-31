---
layout: default
title: Receitas
permalink: /recipes/
---

{%-include back_link.html-%}

# 📚 Receitas

{% for recipe in site.recipes %}
## [{{ recipe.title }}]({{ recipe.url }})

{% if recipe.servings or recipe.time or recipe.cuisine %}
<div>
{% if recipe.servings %} {%- include icons/servings.html -%}{{ recipe.servings }} • {% endif %}
{% if recipe.time %} {%- include icons/clock.html -%}{{ recipe.time }} • {% endif %}
{% if recipe.cuisine %} {%- include icons/globe.html -%}{{ recipe.cuisine }}{% endif %}
</div>
{% endif %}

[Ver receita →]({{ recipe.url }}) • [📥 Baixar .cook](/assets/recipes/{{ recipe.slug }}.cook)

---
{% endfor %}
