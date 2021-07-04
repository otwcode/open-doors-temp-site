import { CHECK_ITEM, IMPORT_ITEM } from "../actions";

export default function (state = {}, action) {
  switch (action.type) {
    case IMPORT_ITEM:
    case CHECK_ITEM:
      const payload = action.payload;
      const id = Object.keys(payload)[ 0 ];
      const item_response = payload[ id ];
      // Occurs when the server fails, eg with a 500 error
      if (payload[ id ].messages[ 0 ] === undefined) {
        payload[ id ].messages = [ payload[ id ].status ]
      }

      // Since this is an individual item, we want to display its own message not the generic
      // "see individual works" message used on author imports
      console.log(payload[id].works[id])
      if (payload[id].works[id]) {
        const item = payload[id].works[id];
        const response = { ...state, [id]: item };
        return response
      } else {
        const response = { ...state, [ id ]: item_response}
        return response
      }
    default:
      return state;
  }
}