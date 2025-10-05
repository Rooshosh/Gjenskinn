class Value {
    //Only 1 of these will be true
    //Used for determining which input device to give the user
    boolean isBool;
    boolean isInt;
    boolean isFloat;

    //Variable used for changing the value while the program is running
    boolean isChanged = false;

    //Variables to store if the value is a boolean
    boolean state;

    //Variables to store if the value is an integer
    int amountI;
    int lowerBoundI;
    int upperBoundI;

    //Variables to store if the value is a float
    float amountF;
    float lowerBoundF;
    float upperBoundF;

    Value(boolean state) {
        this.state = state;
        this.isBool = true;
    }

    Value(int amountI, int lowerBoundI, int upperBoundI) {
        this.amountI = amountI;
        this.lowerBoundI = lowerBoundI;
        this.upperBoundI = upperBoundI;
        this.isInt = true;
    }

    Value(float amountF, float lowerBoundF, float upperBoundF) {
        this.amountF = amountF;
        this.lowerBoundF = lowerBoundF;
        this.upperBoundF = upperBoundF;
        this.isFloat = true;
    }

    void toggle() {
        state = !state;
        isChanged = true;
    }

    void incrementt() {
        if (isInt) {
            int newAmount = amountI + 1;
            if (newAmount <= upperBoundI) {
                amountI = newAmount;
                isChanged = true;
            }
        }
        else if (isFloat) {
            float newAmount = amountF *= 1.1;
            if (newAmount <= upperBoundF) {
                amountF = newAmount;
                isChanged = true;
            }
        }
    }
    
    void changeQuick(int change) {
      if (change > 0) for (int i = 0; i < change; i++) incrementt();
      if (change < 0) for (int i = 0; i < -change; i++) decrement();
    }

    void decrement() {
        if (isInt) {
            int newAmount = amountI - 1;
            if (newAmount >= lowerBoundI) {
                amountI = newAmount;
                isChanged = true;
            }
        }
        else if (isFloat) {
            float newAmount = amountF *= 0.9;
            if (newAmount >= lowerBoundF) {
                amountF = newAmount;
                isChanged = true;
            }
        }
    }

    void setInt(int amount) {
        amountI = amount;
        isChanged = true;
    }

    void setIntQuiet(int amount) {
        amountI = amount;
    }

    void setFloat(float amount) {
        amountF = amount;
        isChanged = true;
    }
}
