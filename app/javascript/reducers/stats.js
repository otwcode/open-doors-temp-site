import { GET_SITE_STATS } from "../actions";

export default function(state = {}, action) {
  switch (action.type) {
    case GET_SITE_STATS:
      return action.payload.data;
    default:
      return state;
  }
}