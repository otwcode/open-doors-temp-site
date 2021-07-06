import { CHECK_ITEM, IMPORT_ITEM } from "../actions";

export default function (state = {}, action) {
  switch (action.type) {
    case IMPORT_ITEM:
    case CHECK_ITEM:
      const payload = action.payload;
      const id = Object.keys(payload)[ 0 ];
      const item_response = payload[ id ];
      // Occurs when the server fails, eg with a 500 error
      if (!_.isUndefined(item_response)) {
        if (!_.isUndefined(item_response.status) &&
          (_.isUndefined(item_response.messages) || _.isUndefined(item_response.messages[0]))) {
          item_response.messages = [ item_response.status ]
        }

        // Since this is an individual item, we want to display its own message not the generic
        // "see individual works" message used on author imports
        if (item_response.works && item_response.works[ id ]) {
          const item = payload[ id ].works[ id ];
          return { ...state, [ id ]: item }
        } else {
          return { ...state, [ id ]: item_response }
        }
    }
    default:
      return state;
  }
}