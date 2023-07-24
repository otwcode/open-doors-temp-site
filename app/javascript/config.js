export const sitekey = 'opendoorstempsite';
export const authors_path = (letter) => `/${sitekey}/authors${ letter ? `?letter=${letter}` :""}`;
export const ws_protocol = 'ws://';