import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
	// public members and methods
	GetNSet(byte[] array) {
		copyToNewArray(array);
		maxval = 127;
	}
	GetNSet(byte[] array, byte amtToBeCopied) {
		copyToNewArray(array);
		copyToNewArray(array);
	}
	public int size() {
		return array.length();
	}
	public byte[] current() {
		byte[] returnArray = new byte[array.length()];
		for (int i = 0; i < returnArray.length; i++) {
			returnArray[i] = (byte)array.get(i);
		}
		return returnArray;
	}
	public boolean swap(int i, int j) {
		if (array.get(i) <= 0 || array.get(j) >= maxval) {
			return false;
		}
		else {
			int iValue = array.get(i);
			int jValue = array.get(j);
			array.set(i, iValue - 1);
			array.set(j, jValue + 1);
			return true;
		}
	}

	// private members and methods
	private byte maxval;
	private AtomicIntegerArray array;
	private void copyToNewArray(byte[] inputArray) {
		int inputArraySize = inputArray.length;
		int[] newArray = new int[inputArraySize];
		for (int i = 0; i < inputArraySize; i++) {
			newArray[i] = inputArray[i];
		}
		array = new AtomicIntegerArray(newArray);
	}

} 