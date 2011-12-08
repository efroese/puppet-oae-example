import 'nodes'

stage { 'first': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

class {
      'preview_processor': stage => first;
      'preview_processor::openoffice': stage => main;
      'preview_processor::gems':   stage => last;
}
