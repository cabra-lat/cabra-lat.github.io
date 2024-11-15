<!DOCTYPE html>
<html lang="{{ page.lang | default: "en" }}">
  {%- include head.html -%}
  <body a="{{ site.theme_config.appearance | default: "auto" }}">

    {%-include back_link.html-%}

    <h1>{{ page.title }}</h1>

    {{ content }}

    {% if page.custom_js %}
      {% for js_file in page.custom_js %}
        <script type="module" src="{{ site.baseurl }}/assets/js/{{ js_file }}.js"></script>
      {% endfor %}
    {% endif %}
  </body>
</html>