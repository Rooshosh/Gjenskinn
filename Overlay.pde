class Box {
    float x;
    float y;
    float w;
    float h;
    float xOff;
    float yOff;

    Box(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    Box(float x, float y, float w, float h, float xOff, float yOff) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.xOff = xOff;
        this.yOff = yOff;
    }
}

class Overlay extends Box {
    PGraphics canvas;

    HashMap<String, Value> values;
    OverlayElement[] elements;

    float margin = 20;
    float padding = margin;
    float inset = margin + padding;

    float contentHeight = h - 2 * inset;
    float contentWidth  = w - 2 * inset;

    float elementHeight;
    float elementWidth = w - 2 * inset;
    float elementSpacing = 5;

    Overlay(HashMap<String, Value> values, float x, float y, float w, float h) {
        super(x, y, w, h);

        canvas = createGraphics((int)w, (int)h);

        this.values = values;

        int elementCount = values.size();
        elementHeight = contentHeight / elementCount - elementSpacing;

        elements = new OverlayElement[values.size()];

        //Populate the array of overlay elements
        int elementIndex = 0;
        for (Map.Entry<String, Value> entry : values.entrySet()) {
            String valueName = entry.getKey();
            Value value = entry.getValue();
            
            OverlayElement element = new OverlayElement(
                inset,
                inset + elementIndex * (elementHeight+elementSpacing),
                elementWidth,
                elementHeight,
                valueName,
                value,
                new PVector(x, y)
            );

            elements[elementIndex] = element;

            elementIndex++;
        }
    }

    boolean checkHover() {
        if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) return true;
        return false;
    }

    void handlePress(float pX, float pY) {
        for (OverlayElement element : elements) {
            //Change the x and y values to correct for the fact that the canvas operates from (0, 0)
            if (element.device.handlePress(pX, pY)) break;
        }
    }
 //<>//
    void display() {
        canvas.beginDraw();
        
        //Draw the main box / Overlay background
        canvas.noStroke();
        canvas.fill(255);
        canvas.rect(margin, margin, w - 2 * margin, h - 2 * margin);
        
        //Draw each of the overlay elements
        for (OverlayElement element : elements) {
            element.display(canvas);
        }
        canvas.endDraw();

        image(canvas, x, y);
    }
}

class OverlayElement extends Box {
    String valueName;
    Value value;
    InputDevice device;

    color backgroundColor = color(230);

    int textSize;
    float textX;
    float textYU;
    float textYL;

    OverlayElement(float x, float y, float w, float h, String valueName, Value value, PVector offset) {
        super(x, y, w, h);

        this.valueName = valueName;
        this.value = value;
        
        createInputDevice(offset);

        textSize = (int)h/4;
        textX = x + w/20;
        textYU = y + h * 1/4;
        textYL = y + h * 3/4;
    }

    void createInputDevice(PVector offset) {
        boolean instantUpdate = true;
        // Previously had an "apply"-button on the particle amount slider
        // if (valueName == "particleAmount") instantUpdate = false;

        InputDevice device = new InputDevice(
            x + w * 3/4,
            y,
            w * 1/4,
            h,
            value,
            offset,
            instantUpdate
        );

        this.device = device;
    }

    void display(PGraphics canvas) {
        //Draw the background of the element
        canvas.fill(backgroundColor);
        canvas.rect(x, y, w, h);

        //Draw the text of the element
        canvas.fill(0);
        canvas.textSize(textSize);
        canvas.textAlign(LEFT, CENTER);

        canvas.text(valueName, textX, textYU);

        //Draw the value of the element
        String textString = "";
        if (value.isBool) textString = str(value.state);
        else if (value.isInt) textString = str(value.amountI);
        else if (value.isFloat) textString = str(value.amountF);
        
        canvas.text(textString, textX, textYL);

        //Draw the input method of the element
        device.display(canvas);
    }
}
