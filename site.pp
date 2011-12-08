import 'manifests/*'
import 'nodes'

stage { 'init': before => Stage['first'] }
stage { 'first': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

class {
      'centos': stage => init;
      'preview_processor': stage => first;
      'preview_processor::openoffice': stage => main;
      'preview_processor::gems':   stage => last;
}
