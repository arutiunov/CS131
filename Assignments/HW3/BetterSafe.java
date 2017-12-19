import java.util.concurrent.locks.ReentrantLock;

class BetterSafe implements State {
	// public members and methods
	BetterSafe(byte[] value) {
		array = value;
		maxval = 127;
		lock = new ReentrantLock();
	}
	BetterSafe(byte[] value, byte size) {
		array = value;
		maxval = size;
		lock = new ReentrantLock();
	}
	public int size() {
		return array.length;
	}
    public byte[] current() {
    	return array;
    }
    public boolean swap(int i, int j) {
    	lock.lock();
    	if (array[i] <= 0 || array[j] >= maxval) {
    		lock.unlock();
    		return false;
    	}
    	else {
    		array[i]--;
    		array[j]++;
    		lock.unlock();
    		return true;
    	}
    }

    // private members and methods
    private byte maxval;
	private byte[] array;
	private ReentrantLock lock;
}