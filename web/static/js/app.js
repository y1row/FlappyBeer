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

class SocketHandler {
  constructor(ctrl) {
    if (SocketHandler.instance) {
      SocketHandler.instance.controller = ctrl;
      return SocketHandler.instance
    }
    SocketHandler.instance = this;
    this.controller = ctrl;
    this.messages = m.prop([]);
    this.socket = new Socket("/socket");
    this.socket.connect();
    this.channel = null
  }

  login(name) {
    this.channel = this.socket.channel("rooms:lobby", {name: name});
    this.channel.on("new_msg", payload => {
      m.startComputation();
      this.messages().splice(0, 0, payload);
      m.endComputation()
    });
    this.channel.join()
      .receive("ok", resp => {
        console.log("login ok: %o", resp);
        login = true;
        this.messages(resp.messages);
        this.controller.loginResult(true);

        $("#login").transition({opacity: 0}, 500, 'ease', function(){
          $("#login").remove();
          awake();
        });
      })
      .receive("error", resp => {
        console.log("login error: %o", resp);
        this.controller.loginResult(false)
      })
  }

  send(message) {
    this.channel.push("new_msg", {body: message})
  }
}

let LoginPage = {
  controller() {
    this.name = m.prop("");
    this.error = m.prop("");
    this.login = () => {
      let socket = new SocketHandler(this);
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
      m("input#name[type=text]", {
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
