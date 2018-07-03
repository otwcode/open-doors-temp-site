(function() {
  this.debug = function(data) {
    return console.log(JSON.stringify(data, null, 4));
  };

  this.clearAllMessages = function(authorId) {
    console.log("clear all messages");
    return $("#author-" + authorId + " .message").empty();
  };

  this.divClass = function(status) {
    debug(status);
    if (status === "ok" || status === "created" || status === "success" || status === "found") {
      return "alert alert-info";
    } else {
      return "alert alert-danger";
    }
  };

  this.alertHTML = function(status, message) {
    return "<div class=\"" + (divClass(status)) + "\" role=\"alert\">" + message + "</div>";
  };

  this.ao3linkHTML = function(url) {
    return "<a href=\"" + url + "\" target=\"_blank\">" + url + "</a>";
  };

  this.importButtonHTML = function(type, itemId) {
    return "<a id=\"item-import-" + type + "-" + itemId + "\" class=\"btn-sm btn-import\" data-method=\"post\" data-button=\"import\" data-item=\"" + itemId + "\" data-type=\"" + type + "\" data-remote=\"true\" href=\"/items/import/" + type + "/" + itemId + "\">Import</a>";
  };

  this.disableButton = function(button) {
    button.addClass("progress-bar-striped progress-bar-animated");
    return button.prop("disabled", true);
  };

  this.enableButton = function(button) {
    button.removeClass("progress-bar-striped progress-bar-animated");
    return button.prop("disabled", false);
  };

  this.toggleToShowAll = function(buttons, allImportedAuthors) {
    buttons = $(".btn-hide-all");
    allImportedAuthors = $("article.imported");
    buttons.text("Show imported authors");
    buttons.attr("data-button", "showAllImported");
    return allImportedAuthors.hide();
  };

  this.toggleToHideAll = function(buttons, allImportedAuthors) {
    buttons = $(".btn-hide-all");
    allImportedAuthors = $("article.imported");
    buttons.text("Hide imported authors");
    buttons.attr("data-button", "hideAllImported");
    return allImportedAuthors.show();
  };

  this.refreshAudit = function(type, itemId) {
    var host, itemAudit, match, myRegexp, path, sitename;
    if ((type != null) && (itemId != null)) {
      itemAudit = $("#audit-" + type + "-" + itemId);
      path = window.location.pathname;
      host = window.location.protocol + "//" + window.location.host;
      myRegexp = /(?:\/)(.*?)(?:\/|$)/g;
      match = myRegexp.exec(path);
      sitename = match[1];
      return $.ajax({
        type: "GET",
        url: host + "/" + sitename + "/items/audit/" + type + "/" + itemId,
        dataType: "text",
        success: function(data, status, xhr) {
          itemAudit.html(data);
          return $("#info-img-" + type + "-" + itemId).show();
        },
        error: function(data, status, error) {
          return console.log("Refresh audit error: " + error);
        },
        complete: function(xhr, status) {
          return console.log("Refresh audit complete");
        }
      });
    }
  };

  this.writeItemToDiv = function(type, status, itemId, message, url) {
    var importButton, mainDiv, messageDiv;
    messageDiv = $("#" + type + "-" + itemId + " .message");
    messageDiv.html(alertHTML(status, message));
    mainDiv = $("#" + type + "-" + itemId);
    if (status === "created" || status === "already_imported" || status === "found") {
      console.log("found");
      mainDiv.addClass("imported");
      importButton = $("#import-" + type + "-" + itemId);
      importButton.html(ao3linkHTML(url));
    }
    if (status === "bad_request" || status === "not_found") {
      console.log("not found");
      mainDiv.removeClass("imported");
      importButton = $("#import-" + type + "-" + itemId);
      return importButton.html(this.importButtonHTML(type, itemId));
    }
  };

  this.writeSummaryToDiv = function(data, summaryTargetDiv, status, authorId) {
    var summary;
    console.log("\nwriteSummaryToDiv");
    debug(data);
    summary = [];
    if (data[0] && data[0]["messages"]) {
      summary.push(data[0]["messages"]);
    }
    if (data[1] && data[1]["messages"]) {
      summary.push(data[1]["messages"]);
    }
    if (summary.length > 0) {
      return summaryTargetDiv.html(alertHTML(status, summary.join("<br/>")));
    }
  };

  this.processImportResponse = function(data) {
    console.log("\nprocessImportResponse");
    debug(data[0]["works"]);
    if (data[0].hasOwnProperty("works")) {
      data[0]["works"].forEach(function(item, idx) {
        refreshAudit("story", item["original_id"]);
        return writeItemToDiv("story", item["status"], item["original_id"], item["messages"].join("<br/>"), item["archive_url"]);
      });
    }
    if (data[0].hasOwnProperty("bookmarks")) {
      data[0]["bookmarks"].forEach(function(item, idx) {
        debug(item);
        refreshAudit("bookmark", item["original_id"]);
        return writeItemToDiv("bookmark", item["status"], item["original_id"], item["messages"].join("<br/>"), item["archive_url"]);
      });
    }
    if (data[1] && data[1].hasOwnProperty("bookmarks")) {
      return data[1]["bookmarks"].forEach(function(item, idx) {
        debug(item);
        refreshAudit("bookmark", item["original_id"]);
        return writeItemToDiv("bookmark", item["status"], item["original_id"], item["messages"].join("<br/>"), item["archive_url"]);
      });
    }
  };

  this.bindImport = function(event) {
    var authorArticle, authorId, authorItems, button, buttonType, itemId, itemSection, summaryDiv, type;
    button = $(event.target);
    buttonType = button.attr("data-button");
    type = button.attr("data-type");
    authorId = button.attr("data-author");
    itemId = button.attr("data-item");
    clearAllMessages(authorId);
    authorArticle = $("#author-" + authorId);
    itemSection = $("#" + type + "-" + itemId);
    if (authorId) {
      authorItems = $("#items-" + authorId);
    } else {
      authorItems = itemSection.parent();
      authorArticle = authorItems.parent();
    }
    summaryDiv = $("#author-" + authorId + " .author.message");
    if (buttonType === "import" || buttonType === "mark" || buttonType === "dni" || buttonType === "check") {
      disableButton(button);
      disableButton(authorArticle);
      $.ajax({
        type: "POST",
        url: button[0],
        dataType: "json",
        success: function(data, status, xhr) {
          var itemImport;
          enableButton(button);
          enableButton(authorArticle);
          writeSummaryToDiv(data, summaryDiv, status, authorId);
          if (data[0]["author_imported"]) {
            authorItems.removeClass("expanded");
            authorItems.addClass("collapse");
            authorArticle.addClass("imported");
          } else {
            authorItems.removeClass("collapse");
            authorItems.addClass("expanded");
            authorArticle.removeClass("imported");
          }
          switch (buttonType) {
            case "import":
              return processImportResponse(data, summaryDiv);
            case "check":
              return processImportResponse(data, summaryDiv);
            case "dni":
              if (data[0]["dni"] === true) {
                if (authorId) {
                  authorArticle.addClass("do_not_import");
                }
                if (itemId) {
                  itemSection.addClass("do_not_import");
                }
                button.text("Mark as ALLOW import");
                authorArticle.find("a[data-button='import']").hide();
                itemSection.find("a[data-button='import']").hide();
              } else {
                if (authorId) {
                  authorArticle.removeClass("do_not_import");
                }
                if (itemId) {
                  itemSection.removeClass("do_not_import");
                }
                button.text("Mark as do NOT import");
                authorArticle.find("a[data-button='import']").show();
                itemImport = itemSection.find("a[data-button='import']");
                itemImport.attr("hidden", false);
                itemImport.show();
              }
              return refreshAudit(type, itemId);
            case "mark":
              if (data[0]["mark"] === true) {
                authorArticle.addClass("imported");
                itemSection.addClass("imported");
                button.text("Mark as NOT imported");
                $("#author-" + authorId + " a[data-button='import']").hide();
                itemSection.find("a[data-button='import']").hide();
              } else {
                authorArticle.removeClass("imported");
                itemSection.removeClass("imported");
                button.text("Mark as imported");
                $("#author-" + authorId + " a[data-button='import']").show();
                itemSection.find("a[data-button='import']").show();
              }
              return refreshAudit(type, itemId);
            default:
              return alert("Unknown button");
          }
        },
        error: function(data, status, error) {
          var itemDiv, message;
          enableButton(button);
          enableButton(authorArticle);
          message = "<p class=\"alert alert-danger\">An error occurred while processing the request: " + error + "</p>";
          summaryDiv.html(message);
          itemDiv = itemSection.find(" .message");
          itemDiv.html(message);
          return debug(data);
        }
      });
    } else if (buttonType === "clear") {
      clearAllMessages(authorId);
    } else if (buttonType === "audit") {
      refreshAudit(type, id);
    } else if (buttonType === "hideAllImported" || buttonType === "showAllImported") {
      if (buttonType === "hideAllImported") {
        toggleToShowAll();
      } else {
        toggleToHideAll();
      }
    } else {
      alert("Unknown button - something is broken!");
    }
    event.preventDefault();
    return false;
  };

  $(function() {
    $("body").on("click", "a[data-button]", bindImport);
    return $.ajaxSetup({
      beforeSend: function(xhr) {
        return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }
    });
  });

}).call(this);

