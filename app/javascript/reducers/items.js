import { IMPORT_ITEM } from "../actions";

export default function (state = {}, action) {
  switch (action.type) {
    case IMPORT_ITEM:
      console.log("IMPORT ITEMS");
      console.log(action.payload);
      const thing = action.payload;
      const id = Object.keys(thing)[0];
      const item = thing[id].works[`${id}`];
      const response = { ...state, ...item };
      return response;
    default:
      return state;
  }
}