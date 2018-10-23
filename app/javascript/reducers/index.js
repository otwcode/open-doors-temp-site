import { combineReducers } from "redux";
import StatsReducer from "./stats";
import AuthorReducer from "./authors";

const rootReducer = combineReducers({
  stats: StatsReducer,
  authorItems: AuthorReducer
});

export default rootReducer;
