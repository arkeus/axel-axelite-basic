package {
	import org.axgl.Ax;
	import org.axgl.AxRect;
	import org.axgl.AxSprite;
	import org.axgl.AxVector;
	import org.axgl.input.AxKey;

	public class Player extends AxSprite {
		public function Player(x:Number, y:Number, worldWidth:Number, worldHeight:Number) {
			super(x, y);
			
			load(Resource.PLAYER, 18, 15);
			addAnimation("stand", [0]);
			addAnimation("walk", [0, 1, 2, 1], 10, true);
			
			terminal = new AxVector(150, 500);
			drag.x = 400;
			acceleration.y = 600;
			worldBounds = new AxRect(0, 0, worldWidth, worldHeight);
		}
		
		override public function update():void {
			if (Ax.keys.down(AxKey.RIGHT)) {
				acceleration.x = 500;
				facing = RIGHT;
			} else if (Ax.keys.down(AxKey.LEFT)) {
				acceleration.x = -500;
				facing = LEFT;
				flip
			} else {
				acceleration.x = 0;
			}
			
			if (Ax.keys.pressed(AxKey.SPACE) && isTouching(DOWN)) {
				velocity.y = -360;
			}
			
			if (velocity.x != 0) {
				animate("walk");
			} else {
				animate("stand");
			}
			
			super.update();
		}
	}
}
