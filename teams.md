---
layout: page
permalink: /teams/
title: teams
description: working with development teams
published: false
---
<ul class="post-list">
{% for page in site.development reversed %}
    <li>
        <h2><a class="agile-title" href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a></h2>
        <p class="post-meta">{{ page.date | date_to_string }}</p>
    </li>
{% endfor %}
</ul>