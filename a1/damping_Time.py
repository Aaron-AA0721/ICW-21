import csv
import math
import numpy as np
import a1
def calculate_damping_time(m1, k1, l1,f1,m2,k2,l2,f2):
    """
    Calculate the damping time (time constant) for a damped harmonic oscillator.

    Parameters:
        m (float): Mass
        k (float): Stiffness
        lambda_ (float): Damping ratio

    Returns:
        float: Damping time (tau)
    """
    if m1 <= 0 or k1<= 0 or l1 <= 0:
        return (0,0,0,0)
        raise ValueError("Mass, stiffness, and damping ratio must be positive.")

    # # Calculate natural frequency (omega_n)
    # omega_n = math.sqrt(k / m)

    # # Calculate damping time (tau)
    # tau = 1 / (lambda_ * omega_n)
    hz = np.linspace(0, 15, 10001)
    sec = np.linspace(0, 30, 10001)
    origin = a1.getTime(hz, sec, m1, l1, k1,f1,m2,l2,k2,f2)
    bl = l2
    ba = origin[0]
    score = 1
    bt=origin[2]
    for i in range(10):
        tr = a1.getTime(hz, sec, m1, l1, k1,f1,m2,l2*(pow(1.585,i))/100.0,k2,f2)
        if origin[0]/tr[0] * origin[2]/tr[2]>score:
            score = origin[0]/tr[0] * origin[2]/tr[2]
            bl = l2*(pow(1.585,i))/100.0
            ba = tr[0]
            bt = tr[2]
    return (bt,bl,ba,origin[0])

def process_csv(input_file, output_file):
    """
    Process a CSV file containing m, k, f, and λ, and compute damping times.

    Parameters:
        input_file (str): Path to the input CSV file.
        output_file (str): Path to the output CSV file.
    """
    with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames + ['Damping Time (tau)'] +['best l'] + ['amp']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)

        writer.writeheader()
        i=0
        for row in reader:
            i+=1
            print(i,"row")
            try:
                # Extract values from the row
                m1 = float(row['m1'])
                k1 = float(row['k1'])
                l1 = float(row['l1'])
                f1 = float(row['f'])
                m2 = float(row['m2'])
                k2 = float(row['k2'])
                l2 = float(row['l2'])
                # Calculate damping time
                res = calculate_damping_time(m1, k1, l1,f1,m2,k2,l2,0)

                # Add damping time to the row
                row['Damping Time (tau)'] = res[0]
                row['best l'] = res[1]
                if(res[2]!=0):
                    row['amp'] = res[2]
                    print(res[0],res[1],res[2])
                else:
                    row['amp'] = 0
                    print(res[0],res[1],0)
                    
                #row['oramp'] = res[3]
                
                # Write the updated row to the output file
                writer.writerow(row)
            except ValueError as e:
                print(f"Skipping row due to error: {e}")

if __name__ == "__main__":
    input_csv = "test.csv"  # Replace with your input CSV file path
    output_csv = "output.csv"  # Replace with your output CSV file path

    process_csv(input_csv, output_csv)
    print(f"Damping times have been calculated and saved to {output_csv}")