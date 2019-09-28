{% macro render(display_toc) %}
  <div class="sidebar-toggle">
    <div class="sidebar-toggle-line-wrap">
      <span class="sidebar-toggle-line sidebar-toggle-line-first"></span>
      <span class="sidebar-toggle-line sidebar-toggle-line-middle"></span>
      <span class="sidebar-toggle-line sidebar-toggle-line-last"></span>
    </div>
  </div>

  <aside class="sidebar">
    <div class="sidebar-inner">

      {%- set display_toc = theme.toc.enable and display_toc %}
      {%- if display_toc %}
        {%- set next_toc_number = page.toc_number | default(theme.toc.number) %}
        {%- set next_toc_max_depth = page.toc_max_depth | default(theme.toc.max_depth) | default(6) %}
        {%- set toc = toc(page.content, { "class": "nav", list_number: next_toc_number, max_depth: next_toc_max_depth }) %}
        {%- set display_toc = toc.length > 1 and display_toc %}
      {%- endif %}

      <ul class="sidebar-nav motion-element">
        <li class="sidebar-nav-toc">
          {{ __('sidebar.toc') }}
        </li>
        <li class="sidebar-nav-overview">
          {{ __('sidebar.overview') }}
        </li>
      </ul>

      <!--noindex-->
      <div class="post-toc-wrap sidebar-panel">
        {%- if display_toc %}
          <div class="post-toc motion-element">{{ toc }}</div>
        {%- endif %}
      </div>
      <!--/noindex-->

      <div class="site-overview-wrap sidebar-panel">
        {{ partial('_partials/sidebar/site-overview.swig', {}, {cache: theme.cache.enable}) }}

        {{- next_inject('sidebar') }}
      </div>

      {%- if theme.back2top.enable and theme.back2top.sidebar %}
        <div class="back-to-top motion-element">
          <i class="fa fa-arrow-up"></i>
          <span>0%</span>
        </div>
      {%- endif %}
      {% include '../_custom/clock.swig' %}

      <script type="text/javascript" src="//rf.revolvermaps.com/0/0/8.js?i=5r913oycw3y&amp;m=0c&amp;c=9d8b63&amp;cr1=0006ff&amp;f=arial&amp;l=33&amp;s=170&amp;cw=ffffff&amp;cb=000000" async="async"></script>

      <!--div id="music163player">
      <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=110 src="//music.163.com/outchain/player?type=0&id=2983866105&auto=1&height=90"></iframe>
      </div-->

    </div>
  </aside>
  <div id="sidebar-dimmer"></div>
{% endmacro %}
