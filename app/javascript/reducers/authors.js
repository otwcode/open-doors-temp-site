import { CHECK_AUTHOR, DNI_AUTHOR, GET_AUTHOR_ITEMS, IMPORT_AUTHOR } from "../actions";
import _ from "lodash";

const payload_items = (payload, state, key) => {
  console.log("Redux state")
  console.log(state)

  function getPayloadItems(keys) {
    return author_payload ?
      keys
        .filter(type => typeof author_payload[ type ] !== 'undefined')
        .map(type => {
          return { ...author_payload[ type ] }
        })[ 0 ] : {};
  }
  function getStateItems(key) {
    return (!_.isEmpty(state) && state[ authorId ]) ? state[ authorId ].items[key] : {};
  }

  const authorId = Object.keys(payload)[ 0 ];
  const author_payload = !(_.isEmpty(payload)) ? payload[ authorId ][ key ] : undefined;

  // Work and bookmark messages
  const works = getPayloadItems([ 'works', 'stories' ]);
  const stories = getStateItems("stories");
  const bookmarks = getPayloadItems(['bookmarks', 'story_links']);
  const story_links = getStateItems("story_links");

  const { author_imported, messages, remote_host, status, success } =
    (_.isEmpty(payload)) ? {} : author_payload;

  const final_messages = (_.isEmpty(messages) && state[ authorId ]) ? state[ authorId ].messages : messages;
  const final_success = (_.isUndefined(success) && state[ authorId ]) ? state[ authorId ].success : success;

  return {
    ...state[ payload.authorId ],
    authorId, author_imported, remote_host, status,
    success: final_success,
    messages: final_messages,
    items: {
      stories: _.merge(stories, works),
      story_links: _.merge(story_links, bookmarks)
    }
  }
};

export default function (state = {}, action) {
  switch (action.type) {
    case IMPORT_AUTHOR:
    case CHECK_AUTHOR:
    case DNI_AUTHOR: {
      console.log("IMPORT, DNI or CHECK");
      const payload = payload_items(action.payload, state, 'import');
      console.log("payload");
      console.log(payload);
      return { ...state, [ payload.authorId ]: payload };
    }
    case GET_AUTHOR_ITEMS: {
      console.log("GET ITEMS");
      const payload = payload_items(action.payload, state, 'items');
      console.log("payload");
      console.log(payload);
      return { ...state, [ payload.authorId ]: payload };
    }
    default:
      return state;
  }
}