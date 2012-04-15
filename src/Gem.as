package {
	import org.axgl.AxSprite;

	public class Gem extends AxSprite {
		public function Gem(tileX:uint, tileY:uint) {
			super(tileX * 24, tileY * 24, Resource.GEM);
		}
	}
}