<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements 9 programmable digital recurrent LIF neurons. The neurons are arranged in 3 layers (3 in each). Spikes_in directly maps to the inputs of the first layer neurons. When an input spike is received, it is first multiplied by an 8 bit weight, programmable from a custom interface, 1 per input neuron. This 8 bit value is then added to the membrane potential of the respective neuron. 
When the first layer neurons activate, its pulse is routed to each of the 3 neurons in the next layer.
There are 9x3 programmable weights describing the connectivity between the input spikes and the first layer (9 weights=3x3), the first and second layers (9 weights=3x3), and second and third layers (9 weights=3x3).
Output spikes from the 3nd layer drive spikes_out. 


## How to test

After reset, program the neuron threshold, leak rate, feedback_scale and refractory period.
Additionally program the first, 2nd, 3rd layer weights. Once programmed activate spikes_in to represent input data, track spikes_out synchronously (1 clock cycle pulses). 


## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
