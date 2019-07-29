---
layout: page
permalink: "/swiftui/"
title: swiftui
description: Exploring SwiftUI.
published: false
---

<ul class="post-list">
{% for post in site.swiftui reversed %}
    <li>
        <h2><a class="poem-title" href="{{ poem.url | prepend: site.baseurl }}">{{ post.title }}</a></h2>
        <p class="post-meta">{{ post.date | date: '%B %-d, %Y — %H:%M' }}</p>
      </li>
{% endfor %}
</ul>

