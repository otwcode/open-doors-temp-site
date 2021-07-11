function getPayloadItems(author_payload, keys) {
  return author_payload ?
    keys
      .filter(type => typeof author_payload[ type ] !== 'undefined')
      .map(type => {
        return { ...author_payload[ type ] }
      })[ 0 ] : {};
}