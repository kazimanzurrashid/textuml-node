module.exports =
  testUrl: (paths...) ->
    baseUrl = 'http://localhost:3000'
    return baseUrl + '/' unless paths.length
    baseUrl + paths.join '/'

  repeatString: (length = 1, character = 'x') ->
    (new Array(length + 1)).join character