<h1>Issue</h1>
<p>I can make this work with either proxy working,  or htaccess working, but not both.</p>
<p>See saltstack/salt/files/etc/apache2/includes/local.com for Apache configuration.</p>
<p>Once you uncomment the proxy settings - the htaccess file in website/htdocs/admin/.htaccess no longer works.</p>

<h3>This is running in Docker</h3>
<p>We've used a 'multi-stage' Docker build to spin up CommandBox with Adobe's JDK running on Debian server</p>
<p>We've installed the Mail package via CFPM</p>
<p>We've configured server via CFConfig</p>

<h3>Site</h3>
<ul>
	<li>Site (proxy): <a href="http://local.local/admin/">http://local.local/admin/</a></li>
	<li>Site: 8080: <a href="http://local.local:8080/htdocs/admin/">http://local.local:8080/htdocs/admin/</a></li>
</ul>

<h3>CFAdmin</h3>
<p>ColdFusion Admin:  (password is 'password')</p>

<ul>
	<li>CFAdmin Proxy: <a href="http://local.local/CFIDE/administrator">CFAdmin</a> - http://local.local/CFIDE/administrator/</li>
	<li>Port 8080: <a href="http://local.local:8080/CFIDE/administrator">CFAdmin</a> - http://local.local:8080/CFIDE/administrator/</li>
</ul>

<p>If the date is not displayed below - Apache is serving the page</p>
<p>If the date is displayed below - ColdFusion is serving the page via the proxy</p>

<h2><cfoutput>#Now()#</cfoutput></h2>
<cfdump var="#server#" abort="false" format="html" label="dump - debugging">
<cfdump var="#cgi#" abort="false" format="html" label="dump - debugging">