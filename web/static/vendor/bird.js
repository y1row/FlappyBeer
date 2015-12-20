/**
 * bird (beer) class
 */
var Bird = function (dom) {
    this.gravity = 0.25;
    this.velocity = 0;
    this.position_x = 60;
    this.position_y = 180;
    this.rotation = 0;
    this.jump_y = -4.6;
    this.dom = dom;
};

Bird.prototype.setDefault = function () {
    //set the defaults (again)
    this.velocity = 0;
    this.position_x = 60;
    this.position_y = 180;
    this.rotation = 0;

    $(this.dom).css({y: 0, x: 0});
};

Bird.prototype.update = function () {
    //update the player speed/position
    this.velocity += this.gravity;
    this.position_x += 2.22;
    this.position_y += this.velocity;

    //rotation
    this.rotation = Math.min((this.velocity / 10) * 90, 90);

    //apply rotation and position
    $($(this.dom)).css({rotate: this.rotation, top: this.position_y});
};

Bird.prototype.jump = function () {
    this.velocity = this.jump_y;
};

Bird.prototype.dead = function () {
    //drop the bird to the floor
    var playerbottom = $(this.dom).position().top + $(this.dom).width(); //we use width because he'll be rotated 90 deg
    var floor = $("#flyarea").height();
    var movey = Math.max(0, floor - playerbottom);
    $(this.dom).transition({y: movey + 'px', rotate: 90}, 1000, 'easeInOutCubic');
};
