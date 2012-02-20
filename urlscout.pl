use Purple;
use HTML::HeadParser;
use LWP::UserAgent;

%PLUGIN_INFO = (
	perl_api_version => 2,
	name => "URLScout",
	version => "0.1",
	summary => "Plugin displaying web page titles when url is received.",
	description => "Plugin displaying web page titles when url is received.",
	author => "necc <necc@necc.cx>",
	url => "http://code.google.com/p/urlscout/",
	load => "plugin_load",
	unload => "plugin_unload"
	#	prefs_info => "prefs_info_cb" ## TODO: implement other video metadata (votes, # of hits)
);

sub plugin_init {
	return %PLUGIN_INFO;
}

sub plugin_load {
	my $plugin = shift;
	Purple::Prefs::add_none("/plugins/core/URLScout");
	Purple::Prefs::add_bool("/plugins/core/URLScout/YTrank", 1);
	Purple::Debug::info("URLScout", "plugin_load() - URLScout Plugin Loaded.\n");
	$conv_handle = Purple::Conversations::get_handle();
	$data = "";
	Purple::Signal::connect($conv_handle, "receiving-im-msg", $plugin, \&conv_cb, $data);
	}

sub plugin_unload {
	my $plugin = shift;
	Purple::Debug::info("URLScout", "plugin_unload() - URLScout Plugin Unloaded.\n");
}

#	## TODO: implement other video metadata (votes, # of hits)
sub prefs_info_cb {
	$frame = Purple::PluginPref::Frame->new();
	$ppref = Purple::PluginPref->new_with_label("Show YT score");
	$frame->add($ppref);
	$ppref = Purple::PluginPref->new_with_name_and_label("/plugins/core/URLScout/YTrank", "Show YT score");
	$frame->add($ppref);
	return $frame;
}

sub conv_cb {
	my($account, $who, $msg, $conv, $flags) = @_;	
		
	if ( index($msg, "http:\/\/") > -1 || index($msg, "https:\/\/") > -1 ) {
		$msg =~ m|(\w+)://([^/:]+)(:\d+)?/(.*)|;
		$url =  $1 . ":\/\/".  $2 . "\/" .  $4 ;
		Purple::Debug::info("URLScout", "We've got a url: " . $url . "\n");
		$p = HTML::HeadParser->new;
		$ua = new LWP::UserAgent;
		$ua->timeout(120);

 		$request = new HTTP::Request('GET', $url);
 		$response = $ua->request($request);
 		$content = $response->content();
			
 		$p->parse($content);
 
		Purple::Debug::info("URLScout", "Page title: " . $p->header('Title') . "\n");
		$_[2] = $msg . " \n[" . $p->header('Title') . "]";
	}	
		
}




