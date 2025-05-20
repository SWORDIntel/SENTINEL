![s33](https://github.com/datas0lutions/s3ent/assets/134785585/3bb80195-c0ac-4c37-acd4-bfa664cfa902)




# s3ent
(Anonymous) s3 Enumeration Tool

A simple script to anonymously view all objects within an open S3 container by entering the bucket's name; No AWS credentials or complex setup necessary. 

Intended to highlight the security implications of unprotected AWS s3 file containers which often contain confidential, proprietary, and personally identifiable information (PII).



To use the script, follow these steps:

1. Clone the repository or download `s3ent.py` to your local machine.

2. Make sure you have Python 3 installed on your system.

3. Install the required dependencies
   
   ```shell
   pip3 install boto3 requests
   ```

4. Run the script with the desired options as outlined below:

   ```shell
   python3 s3ent.py -b <bucket_name> [-o <output_file>] [-q]
   ```

   - `-b <bucket_name>` specifies the name of the S3 bucket you want to list.
   - `-o <output_file>` (optional) specifies a custom name for the output file. If not provided, the default output file name will be the same as the bucket name.
   - `-q` (optional) runs the script in quiet mode, which suppresses verbose output. By default, the script runs in verbose mode.

### Examples

1. To list files and folders in an S3 bucket named "test" in verbose mode, and save the output to a file named "test.txt", run the following command:

   ```shell
   python3 s3ent.py -b test -o test.txt
   ```

2. To list files and folders in an S3 bucket named "test" in quiet mode (suppressing verbose output), with the default output file name, run the following command:

   ```shell
   python3 s3ent.py -b test -q
   ```

     
