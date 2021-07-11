import { combineReducers } from "redux";
import StatsReducer from "./stats";
import AuthorReducer from "./authors";
import ItemReducer from "./items";

const rootReducer = combineReducers({
  stats: StatsReducer,
  authorItems: AuthorReducer,
  itemResponse: ItemReducer
});

export default rootReducer;
