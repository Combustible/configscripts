def Settings( **kwargs ):
  if kwargs[ 'language' ] == 'java':
    return {
      'ls': {
        'java.sources.organizeImports.starThreshold': 30,
        'java.completion.importOrder': [
            '',
            '#'
        ]
      }
    }
