import { GET_AUTHOR_ITEMS, IMPORT_AUTHOR } from "../actions";

export default function(state = {}, action) {
  switch (action.type) {
    case IMPORT_AUTHOR:
    case GET_AUTHOR_ITEMS:
      const authorId = Object.keys(action.payload)[0];
      return { ...state, [authorId]: { ...state[authorId], ...action.payload[authorId] } };
    default:
      return state;
  }
}