package {
	import org.axgl.Ax;
	import org.axgl.AxGroup;
	import org.axgl.AxRect;
	import org.axgl.AxSprite;
	import org.axgl.AxState;
	import org.axgl.collision.AxCollider;
	import org.axgl.collision.AxCollisionGroup;
	import org.axgl.collision.AxGrid;
	import org.axgl.particle.AxParticleEffect;
	import org.axgl.particle.AxParticleSystem;
	import org.axgl.render.AxBlendMode;
	import org.axgl.render.AxColor;
	import org.axgl.text.AxText;
	import org.axgl.tilemap.AxTilemap;
	import org.axgl.util.AxRange;

	public class GameState extends AxState {
		private static var TILEMAP_COLLIDER:AxCollisionGroup;
		private static var GEM_COLLIDER:AxCollisionGroup;
		
		public var gemsCollected:uint = 0;
		
		private var tilemap:AxTilemap;
		private var player:Player;
		private var gems:AxGroup;
		private var particles:AxGroup;
		private var gemText:AxText;
		
		override public function create():void {
			super.create();
			
			Ax.music(Resource.MUSIC);
			
			var background:AxSprite = new AxSprite(0, 0, Resource.BACKGROUND);
			background.scroll.x = background.scroll.y = 0;
			add(background);
			
			particles = new AxGroup;
			add(particles);
			
			var effect:AxParticleEffect = new AxParticleEffect("collect-coin", Resource.PARTICLE, 10);
			effect.xVelocity = new AxRange(-70, 70);
			effect.yVelocity = new AxRange(-70, 70);
			effect.lifetime = new AxRange(0.5, 1.5);
			effect.amount = 100;
			effect.blend = AxBlendMode.PARTICLE;
			effect.color(new AxColor(0.3, 0.3, 0.3), new AxColor(1, 1, 1), new AxColor(0.3, 0.3, 0.3), new AxColor(1, 1, 1));
			particles.add(AxParticleSystem.register(effect));
			
			tilemap = new AxTilemap().build(Resource.MAP_DATA, Resource.TILES, 24, 24, 3);
			add(tilemap);
			
			player = new Player(24, 604, tilemap.width, tilemap.height);
			add(player);
			
			gems = new AxGroup;
			add(gems);
			
			var gemArray:Array = Resource.GEMS_DATA.split(",");
			for (var i:uint = 0; i < gemArray.length; i++) {
				if (gemArray[i] == 0) {
					continue;
				}
				var gemX:uint = i % 30;
				var gemY:uint = Math.floor(i / 30);
				var gem:Gem = new Gem(gemX, gemY);
				gems.add(gem);
			}
			
			gemText = new AxText(10, 10, null, "Gems: 0");
			gemText.scroll.x = gemText.scroll.y = 0;
			gemText.scale.x = gemText.scale.y = 4;
			add(gemText);
			
			TILEMAP_COLLIDER = new AxCollider;
			GEM_COLLIDER = new AxGrid(tilemap.width, tilemap.height);
			
			Ax.camera.follow(player);
			Ax.camera.bounds = new AxRect(0, 0, tilemap.width, tilemap.height);
		}
		
		override public function update():void {
			gemText.text = "@[0,0,0]Gems: @[200,70,70]" + gemsCollected;
			
			super.update();
			
			Ax.collide(player, tilemap, null, TILEMAP_COLLIDER);
			Ax.overlap(player, gems, onHitGem, GEM_COLLIDER);
		}
		
		private function onHitGem(player:Player, gem:Gem):void {
			AxParticleSystem.emit("collect-coin", gem.center.x, gem.center.y);
			gem.destroy();
			gemsCollected++;
			Ax.sound(Resource.SOUND, 0.8, false, 70);
		}
	}
}
