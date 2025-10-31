---
layout: default
title: Receitas
permalink: /recipes/
---

{%-include back_link.html-%}

# 📚 Receitas

{% for recipe in site.recipes %}
<div class="recipe-preview">
  <div class="recipe-thumbnail">
    <img src="/assets/recipes/{{ recipe.slug }}.png" alt="{{ recipe.title }}" onerror="this.style.display='none'" />
  </div>
  
  <div class="recipe-info">
    <h2><a href="{{ recipe.url }}">{{ recipe.title }}</a></h2>

    {% if recipe.servings or recipe.time or recipe.cuisine %}
    <div class="recipe-metadata">
      {% if recipe.servings %} <span class="metadata-item">{% include icons/servings.html %}{{ recipe.servings }}</span> {% endif %}
      {% if recipe.time %} <span class="metadata-item">{% include icons/clock.html %}{{ recipe.time }}</span> {% endif %}
      {% if recipe.cuisine %} <span class="metadata-item">{% include icons/globe.html %}{{ recipe.cuisine }}</span> {% endif %}
    </div>
    {% endif %}

    <div class="recipe-links">
      <a href="{{ recipe.url }}">Ver receita →</a> • <a href="/assets/recipes/{{ recipe.slug }}.cook" download>📥 Baixar .cook</a>
    </div>
  </div>
</div>

<hr>
{% endfor %}

<style>
.recipe-preview {
  display: flex;
  gap: 1.5rem;
  margin: 2rem 0;
  align-items: flex-start;
}

.recipe-thumbnail {
  flex-shrink: 0;
  width: 120px;
  height: 120px;
}

.recipe-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #eee;
}

.recipe-info {
  flex: 1;
}

.recipe-info h2 {
  margin: 0 0 0.5rem 0;
}

.recipe-info h2 a {
  text-decoration: none;
  color: inherit;
}

.recipe-info h2 a:hover {
  text-decoration: underline;
}

.recipe-metadata {
  display: flex;
  gap: 1rem;
  margin: 0.5rem 0;
  flex-wrap: wrap;
}

.recipe-metadata .metadata-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: #f8f9fa;
  padding: 0.25rem 0.75rem;
  border-radius: 16px;
  font-size: 0.85rem;
}

.recipe-links {
  margin-top: 0.75rem;
}

.recipe-links a {
  text-decoration: none;
}

.recipe-links a:hover {
  text-decoration: underline;
}

hr {
  border: none;
  border-top: 1px solid #eee;
  margin: 2rem 0;
}
</style>
