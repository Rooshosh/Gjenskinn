class InputDevice extends Box {
    Value value;

    boolean isBool;
    boolean isInt;
    boolean isFloat;

    boolean instantUpdate;

    Scrollbar scrollbar;

    PVector offset;

    InputDevice(float x, float y, float w, float h, Value value, PVector offset, boolean instantUpdate) {
        super(x, y, w, h);

        this.value = value;
        this.instantUpdate = instantUpdate;

        this.offset = offset;

        isBool = value.isBool;
        isInt = value.isInt;
        isFloat = value.isFloat;

        float initialScroll = 0;
        if (isInt) initialScroll = map(value.amountI, value.lowerBoundI, value.upperBoundI, 0.0, 1.0);
        if (isFloat) map(value.amountF, value.lowerBoundF, value.upperBoundF, 0.0, 1.0);

        float scrollBarWidth = w * 2 - 20;
        if (!instantUpdate) scrollBarWidth = w * 2 * 3/4- 20;
        scrollbar = new Scrollbar(x - w + 10, y + 10, scrollBarWidth, h - 20, initialScroll, offset);
    }

    void display(PGraphics canvas) {
        if (isBool) {
            //Draw the background
            canvas.fill(150);
            canvas.rect(x, y, w, h);

            //Draw the toggle text
            canvas.textAlign(CENTER, CENTER);
            canvas.fill(0);
            canvas.text("Toggle", x + w/2, y + h/2);
        }
        else if (isInt) {
            //Let the scrollbar update to check for mouse interaction
            scrollbar.update();

            //Check if the scrollbar got manipulated
            if (scrollbar.hasChanged) {
                int amount = (int)map(scrollbar.val, 0.0, 1.0, value.lowerBoundI, value.upperBoundI);
                if (instantUpdate) value.setInt(amount);
                else value.setIntQuiet(amount);
                scrollbar.hasChanged = false;
            }

            //Draw the scrollbar
            scrollbar.display(canvas);

            //Draw the apply changes button
            if (!instantUpdate) {
                //Draw the background
                canvas.fill(150);
                canvas.rect(x + w/2, y, w/2, h);

                //Draw the toggle text
                canvas.textAlign(CENTER, CENTER);
                canvas.fill(0);
                canvas.text("Apply", x + w*3/4, y + h/2);
            }
        }
        else if (isFloat) {
            //Let the scrollbar update to check for mouse interaction
            scrollbar.update();

            //Check if the scrollbar got manipulated
            if (scrollbar.hasChanged) {
                float amount = map(scrollbar.val, 0.0, 1.0, value.lowerBoundF, value.upperBoundF);
                value.setFloat(amount);
                scrollbar.hasChanged = false;
            }

            //Draw the scrollbar
            scrollbar.display(canvas);
        }
    }

    boolean handlePress(float pX, float pY) {
        //Check if the press was inside of the input element's area.
        if (pX > x + offset.x && pY > y + offset.y && pX < x + w + offset.x && pY < y + h + offset.y) {
            if (isBool) {
                //User pressed the "toggle" button
                value.toggle();
                return true;
            }
            else if (isInt && !instantUpdate && pX > x + w/2) {
                //User pressed the "apply" button
                value.isChanged = true;
                return true;
            }
        }
        return false;
    }
}

//My own scrollbar class
class Scrollbar extends Box{
    boolean isHorizontal;

    float pW = 10;

    float val; // Value of slider between 0.0 and 1.0
    int valI;
    float pX; // Pointer center absolute x value on screen
    float pXMin;
    float pXMax;
    float pWR; //Pointer width range

    float newPX;

    boolean over;
    boolean locked;

    boolean hasChanged = false;

    PVector offset;

    Scrollbar(float x, float y, float w, float h, float initialScroll, PVector offset) {
        super(x, y, w, h);
        this.offset = offset;

        if (w > h) isHorizontal = true;
        else isHorizontal = false;

        val = initialScroll;

        pWR = w - pW;
        pXMin = x + pW/2;
        pXMax = pXMin + pWR;
        pX = pXMin + val*pWR;
        newPX = pX;
    }

    boolean overEvent() {
        if (mouseX > x + offset.x && mouseX < x + w + offset.x &&
            mouseY > y + offset.y && mouseY < y + h + offset.y) {
            return true;
        } else {
            return false;
        }
    }

    float constrain(float val, float minv, float maxv) {
        return min(max(val, minv), maxv);
    }

    void update() {
        if (overEvent()) {
            over = true;
        } else {
            over = false;
        }
        if (mousePressed && over) {
            locked = true;
        }
        if (!mousePressed) {
            locked = false;
        }
        if (locked) {
            newPX = constrain(mouseX -  + offset.x, pXMin, pXMax);
        }
        if (abs(newPX - pX) > 1) {
            pX = pX + (newPX-pX)/16;    // 16 is the loose variable
            val = (pX - pXMin) / pWR;
            hasChanged = true;
        }
    }

    void display(PGraphics canvas) {
        canvas.fill(200);
        canvas.rect(x, y, w, h);
        canvas.fill(50);
        canvas.rect(pX - pW / 2, y, pW, h);
    }
}
