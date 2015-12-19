// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import {Socket} from "deps/phoenix/web/static/js/phoenix"

let login = false;
var high_scores = [];
var user_name;

class LoginModel {
  constructor(ctrl) {
    if (LoginModel.instance) {
      LoginModel.instance.controller = ctrl;
      return LoginModel.instance
    }
    LoginModel.instance = this;
    this.controller = ctrl;
    this.messages = m.prop([]);

    socket = new Socket("/socket");
    socket.connect();
    channel = null
  }

  login(name) {
    user_name = name;

    channel = socket.channel("rooms:lobby", {name: name});
    channel.on("put_score", payload => {
      m.startComputation();
      console.log("scores: %o", payload);

      var hit = false;
      jQuery.each(high_scores, function () {
        if (this.user == payload.user) {
          this.score = payload.body;
          hit = true;
          return;
        }
      });

      if (hit == false) {
        high_scores.push({
          user: payload.user,
          score: payload.body
        });
      }

      this.update_score();
      m.endComputation();
    });
    channel.join()
      .receive("ok", resp => {
        console.log("login ok: %o", resp);
        login = true;
        this.messages(resp.messages);
        this.controller.loginResult(true);

        high_scores = resp;
        this.update_score();

        $("#login").transition({opacity: 0}, 500, 'ease', function () {
          $("#login").remove();
          awake();
        });
      })
      .receive("error", resp => {
        console.log("login error: %o", resp);
        this.controller.loginResult(false)
      })
  }

  update_score() {

    high_scores.sort(function (a, b) {
      if (a.score > b.score) {
        return -1;
      }
      if (a.score < b.score) {
        return 1;
      }
      return 0;
    });
    console.log(high_scores);

    $("#scores").empty();
    $("#scores").append("<table class=\"score\">");
    var rank = 1;
    var me;
    jQuery.each(high_scores, function () {
      me = (user_name == this.user) ? " class=\"me\"" : "";

      $("#scores").append("<tr" + me + "><td>"
        + rank + "</td><td>"
        + this.user + "</td><td>"
        + this.score + "</td></tr>"
      );
      rank++;
    });
    $("#scores").append("</table>");

  }
}

let LoginPage = {
  controller() {
    this.name = m.prop("");
    this.error = m.prop("");
    this.login = () => {
      let socket = new LoginModel(this);
      socket.login(this.name());
    };
    this.loginResult = (isSuccess) => {
      if (isSuccess) {
        m.route("/")
      } else {
        m.startComputation()
        this.error(this.name() + " is already used.")
        this.name("")
        m.endComputation()
      }
    };
    this.onKeyPress = (e) => {
      if ((e.which && e.which === 13) || (e.keyCode && e.keyCode === 13)) {
        this.name(e.target.value)
        this.login()
      } else {
        m.redraw.strategy("none")
      }
    }
  },
  view(ctrl) {
    return m("div", [
      m("label", {for: name}, "enter name"),
      m("input#name[type=text][maxlength=8]", {
        onchange: m.withAttr("value", ctrl.name),
        onkeypress: ctrl.onKeyPress
      }),
      m("button.button", {onclick: ctrl.login}, "Go!"),
      m(".error", ctrl.error())
    ])
  }
};

let ChatPage = {
  controller() {
    if (!login) {
      return m.route("/login")
    }
  }
};

m.route(document.getElementById("login"), "/login", {
  "/login": LoginPage,
  "/": ChatPage
});
